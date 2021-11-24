class ApplicationController < ActionController::Base
    before_action :authenticate_user!, only: :logged_in
    skip_before_action :verify_authenticity_token, only: :saml_callback
    
    SAML_EPPN = "urn:oid:1.3.6.1.4.1.5923.1.1.1.6"
    SAML_NAME = "urn:oid:2.16.840.1.113730.3.1.241"

    def index
    end
  
    def saml_login
      request = OneLogin::RubySaml::Authrequest.new
      redirect_to(request.create(saml_settings))
    end
  
    def saml_callback
      response = OneLogin::RubySaml::Response.new(
        params[:SAMLResponse],
        :settings => saml_settings
      )
    
      if response.is_valid?
        @user = User.create_or_find_by!(eppn: response.attributes[SAML_EPPN])
        @user.update(name: response.attributes[SAML_NAME], last_login: DateTime.now)
        sign_in(@user)
        redirect_to action: 'index'
      else
        raise response.errors.inspect
      end
    end

    def metadata
      settings = saml_settings
      meta = OneLogin::RubySaml::Metadata.new
      render :xml => meta.generate(settings), :content_type => "application/samlmetadata+xml"
    end
  
    private
  
    def saml_settings
      settings = OneLogin::RubySaml::Settings.new
      
      settings.assertion_consumer_service_url = "https://#{request.host_with_port}/saml_callback"
      settings.sp_entity_id                   = "https://blooming-inlet-00991.herokuapp.com"
    
      settings.idp_sso_target_url             = "https://login.stanford.edu/idp/profile/SAML2/Redirect/SSO"
      settings.idp_cert                       = "MIIDnzCCAoegAwIBAgIJAJl9YtyaxKsZMA0GCSqGSIb3DQEBBQUAMGYxCzAJBgNV BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMREwDwYDVQQHDAhTdGFuZm9yZDEU MBIGA1UECgwLSVQgU2VydmljZXMxGTAXBgNVBAMMEGlkcC5zdGFuZm9yZC5lZHUw HhcNMTMwNDEwMTYzMTAwWhcNMzMwNDEwMTYzMTAwWjBmMQswCQYDVQQGEwJVUzET MBEGA1UECAwKQ2FsaWZvcm5pYTERMA8GA1UEBwwIU3RhbmZvcmQxFDASBgNVBAoM C0lUIFNlcnZpY2VzMRkwFwYDVQQDDBBpZHAuc3RhbmZvcmQuZWR1MIIBIjANBgkq hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6466Bd6mDwNOR2qZZy1WRZdjyrG2/xW amGEMekg38fyuoSCIiMcgeA9UIUbiRCpAN87yI9HPcgDEdrmCK3Ena3J2MdFZbRE b6fdRt76K+0FSl/CnyW9xaIlAhldXKbsgUDei3Xf/9P8H9Dxkk+PWd9Ha1RZ9Viz dOLe2S2iDKc1CJg2kdGQTuQu6mUEGrB9WJmrLHJS7GkGDqy96owFjRL/p0i9KBdR kgWG+GFHWkxzeNQ99yrQra3+C9FQXa/xLCdOY+BGOsAG7ej4094NZXRNTyXui4jR WCm2GVdIVl7YB9++XSntS7zQEJ9QBnC1D4bS0tljMfdOGAvdUuJY7QIDAQABo1Aw TjAdBgNVHQ4EFgQUJk4zcQ4JupEcAp0gEkob4YRDkckwHwYDVR0jBBgwFoAUJk4z cQ4JupEcAp0gEkob4YRDkckwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUFAAOC AQEAKvf9AO4+osJZOmkv6AVhNPm6JKoBSm9dr9NhwpSS5fpro6PrIjDZDLh/L5d/ +CQTDzuVsw3xwDtlm89lrzbqw5rSa2+ghJk79ijysSC0zOcD6ka9c17zauCNmFx9 lj9iddUw3aYHQcQRktWL8pvI2WCY6lTU+ouNM+owStya7umZ9rBdjg/fQerzaQxF T0yV3tYEonL3hXMzSqZxWirwsyZ0TnhWJsgEnqqG9tCFAcFu2p+glwXn1WL2GCRv BfuJMPzg7ZB419AEoeYnLktqAWiU+ISnVfbwFOJ+OM/O7VQOeHDm2AeYcwo12CAc 4GC9KWTs3QtS3GREPKYDlHRNxQ=="

      settings.certificate = Rails.application.credentials.sp_cert
      settings.private_key = Rails.application.credentials.sp_key

      settings.security[:want_assertions_encrypted] = true

      settings
    end
  end