class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!, only: :logged_in
  skip_before_action :verify_authenticity_token, only: :saml_callback
  before_action :require_admin, only: :admin
  
  SAML_EPPN = "urn:oid:1.3.6.1.4.1.5923.1.1.1.6"
  SAML_NAME = "urn:oid:2.16.840.1.113730.3.1.241"

  def index
  end

  def saml_login
    saml_request = OneLogin::RubySaml::Authrequest.new
    redirect_to(saml_request.create(saml_settings, :RelayState => request.referrer))
  end

  def saml_callback
    response = OneLogin::RubySaml::Response.new(
      params[:SAMLResponse],
      :settings => saml_settings
    )
  
    if response.is_valid?
      #Check for @stanford.edu
      eppn, domain = response.attributes[SAML_EPPN].split('@',2)
      if not domain == "stanford.edu"
        fail "Not a Stanford EPPN"
      else
        @user = User.create_or_find_by!(id: eppn)
        @user.update(name: response.attributes[SAML_NAME], last_login: DateTime.now)
        sign_in(@user)
      end

      if params[:RelayState]
        redirect_to params[:RelayState]
      else
        redirect_to action: 'index'
      end

    else
      raise response.errors.inspect
    end
  end

  def metadata
    settings = saml_settings
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(settings), :content_type => "application/samlmetadata+xml"
  end

  # Trigger SP and IdP initiated Logout requests
  def saml_logout
    # If we're given a logout request, handle it in the IdP logout initiated method
    if params[:SAMLRequest]
      return idp_logout_request
    # We've been given a response back from the IdP, process it
    elsif params[:SAMLResponse]
      return process_logout_response
    # Initiate SLO (send Logout Request)
    else
      return sp_logout_request
    end
  end

  private

  # Create a SP initiated SLO
  def sp_logout_request
    # LogoutRequest accepts plain browser requests w/o paramters
    settings = saml_settings

    if settings.idp_slo_service_url.nil?
      logger.info "SLO IdP Endpoint not found in settings, executing then a normal logout'"
      delete_session
    else

      logout_request = OneLogin::RubySaml::Logoutrequest.new
      logger.info "New SP SLO for userid '#{current_user.id}' transactionid '#{logout_request.uuid}'"

      if settings.name_identifier_value.nil?
        settings.name_identifier_value = current_user.id
      end

      # Ensure user is logged out before redirect to IdP, in case anything goes wrong during single logout process (as recommended by saml2int [SDP-SP34])
      logged_user = current_user.id
      logger.info "Delete session for '#{current_user.id}'"
      delete_session

      # Save the transaction_id to compare it with the response we get back
      session[:transaction_id] = logout_request.uuid
      session[:logged_out_user] = logged_user

      relayState = url_for(controller: 'application', action: 'index')
      redirect_to(logout_request.create(settings, :RelayState => relayState))
    end
  end

  # After sending an SP initiated LogoutRequest to the IdP, we need to accept
  # the LogoutResponse, verify it, then actually delete our session.
  def process_logout_response
    settings = Account.get_saml_settings

    if session.has_key? :transaction_id
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings, :matches_request_id => session[:transaction_id])
    else
      logout_response = OneLogin::RubySaml::Logoutresponse.new(params[:SAMLResponse], settings)
    end

    logger.info "LogoutResponse is: #{logout_response.to_s}"

    # Validate the SAML Logout Response
    if not logout_response.validate
      logger.error "The SAML Logout Response is invalid"
    else
      # Actually log out this session
      logger.info "SLO completed for '#{current_user.id}'"
      delete_session
    end
  end

  # Delete a user's session.
  def delete_session
    sign_out()
  end

  # Method to handle IdP initiated logouts
  def idp_logout_request
    settings = Account.get_saml_settings
    logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest])
    if !logout_request.is_valid?
      logger.error "IdP initiated LogoutRequest was not valid!"
      return render :inline => logger.error
    end
    logger.info "IdP initiated Logout for #{logout_request.name_id}"

    # Actually log out this session
    delete_session

    # Generate a response to the IdP.
    logout_request_id = logout_request.id
    logout_response = OneLogin::RubySaml::SloLogoutresponse.new.create(settings, logout_request_id, nil, :RelayState => params[:RelayState])
    redirect_to logout_response
  end

  def saml_settings
    settings = OneLogin::RubySaml::Settings.new
    
    settings.assertion_consumer_service_url = "https://#{request.host_with_port}/saml_callback"
    settings.sp_entity_id                   = "https://blooming-inlet-00991.herokuapp.com"
  
    #settings.idp_sso_target_url             = "https://login.stanford.edu/idp/profile/SAML2/Redirect/SSO"
    settings.idp_cert                       = "MIIDnzCCAoegAwIBAgIJAJl9YtyaxKsZMA0GCSqGSIb3DQEBBQUAMGYxCzAJBgNV BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMREwDwYDVQQHDAhTdGFuZm9yZDEU MBIGA1UECgwLSVQgU2VydmljZXMxGTAXBgNVBAMMEGlkcC5zdGFuZm9yZC5lZHUw HhcNMTMwNDEwMTYzMTAwWhcNMzMwNDEwMTYzMTAwWjBmMQswCQYDVQQGEwJVUzET MBEGA1UECAwKQ2FsaWZvcm5pYTERMA8GA1UEBwwIU3RhbmZvcmQxFDASBgNVBAoM C0lUIFNlcnZpY2VzMRkwFwYDVQQDDBBpZHAuc3RhbmZvcmQuZWR1MIIBIjANBgkq hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6466Bd6mDwNOR2qZZy1WRZdjyrG2/xW amGEMekg38fyuoSCIiMcgeA9UIUbiRCpAN87yI9HPcgDEdrmCK3Ena3J2MdFZbRE b6fdRt76K+0FSl/CnyW9xaIlAhldXKbsgUDei3Xf/9P8H9Dxkk+PWd9Ha1RZ9Viz dOLe2S2iDKc1CJg2kdGQTuQu6mUEGrB9WJmrLHJS7GkGDqy96owFjRL/p0i9KBdR kgWG+GFHWkxzeNQ99yrQra3+C9FQXa/xLCdOY+BGOsAG7ej4094NZXRNTyXui4jR WCm2GVdIVl7YB9++XSntS7zQEJ9QBnC1D4bS0tljMfdOGAvdUuJY7QIDAQABo1Aw TjAdBgNVHQ4EFgQUJk4zcQ4JupEcAp0gEkob4YRDkckwHwYDVR0jBBgwFoAUJk4z cQ4JupEcAp0gEkob4YRDkckwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOC AQEAKvf9AO4+osJZOmkv6AVhNPm6JKoBSm9dr9NhwpSS5fpro6PrIjDZDLh/L5d/ +CQTDzuVsw3xwDtlm89lrzbqw5rSa2+ghJk79ijysSC0zOcD6ka9c17zauCNmFx9 lj9iddUw3aYHQcQRktWL8pvI2WCY6lTU+ouNM+owStya7umZ9rBdjg/fQerzaQxF T0yV3tYEonL3hXMzSqZxWirwsyZ0TnhWJsgEnqqG9tCFAcFu2p+glwXn1WL2GCRv BfuJMPzg7ZB419AEoeYnLktqAWiU+ISnVfbwFOJ+OM/O7VQOeHDm2AeYcwo12CAc 4GC9KWTs3QtS3GREPKYDlHRNxQ=="

    settings.idp_sso_service_url            = "https://login.stanford.edu/idp/profile/SAML2/Redirect/SSO"
    settings.idp_sso_service_binding        = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" # or :post, :redirect

    settings.idp_slo_service_url            = "https://login.stanford.edu/idp/profile/Logout"
    settings.idp_slo_service_binding        = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" # or :post, :redirect

    settings.certificate = Rails.application.credentials.sp_cert
    settings.private_key = Rails.application.credentials.sp_key

    settings.security[:want_assertions_encrypted] = true

    settings
  end

  def require_admin
    unless (current_user && current_user.admin)
      flash[:error] = "You must be an admin to access this section"
      redirect_to action: 'index', controller: 'application'
    end
  end

  def require_user
    unless (current_user)
      flash[:error] = "You must be logged in to access this section"
      redirect_to action: 'index', controller: 'application'
    end
  end

end