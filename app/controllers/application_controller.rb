class ApplicationController < ActionController::Base
    before_action :authenticate_user!, only: :logged_in
    skip_before_action :verify_authenticity_token, only: :saml_callback
    
    def index
    end
  
    def logged_in
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
        @user = User.create_or_find_by!(email: response.nameid)
        puts response.nameid
        sign_in(@user)
        redirect_to(:logged_in)
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

      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      # Returns OneLogin::RubySaml::Settings pre-populated with IdP metadata
      settings = idp_metadata_parser.parse_remote("https://login.stanford.edu/metadata.xml")
      
      # You provide to IDP
      settings.assertion_consumer_service_url = "https://blooming-inlet-00991.herokuapp.com/saml_callback"
      settings.sp_entity_id                   = "https://blooming-inlet-00991.herokuapp.com"
    
      settings.certificate = Rails.application.credentials.sp_cert
      settings.private_key = Rails.application.credentials.sp_key

      settings.security[:want_assertions_encrypted] = true

      settings
    end
  end