Rails.application.routes.draw do
  resources :petitions do
    member do
      post 'sign'
      delete 'unsign'
    end
  end

  resources :users

  devise_for :users

  root to: "application#index"
  get 'logged_in', to: "application#logged_in"
  post 'saml_login', to: "application#saml_login"
  post 'saml_callback', to: "application#saml_callback"
  get 'saml_metadata.xml', to: "application#metadata"
  
  get '/:slug', to: "petitions#by_slug"
end
