Rails.application.routes.draw do
  resources :petitions do
    
    member do
      post 'sign'
      delete 'unsign'
    end

    collection do
      get 'leaderboard'
    end
  end

  get 'audit', to: "petitions#audit"

  resources :users
  get 'profile', to: "users#show"

  devise_for :users

  root to: "application#index"
  get 'admin', to: "admin#index"
  patch 'admin', to: "admin#update"

  get 'import', to: "import#index"
  namespace :import do
    post 'review', to: "review"
    post 'apply', to: "apply"
  end

  get 'logged_in', to: "application#logged_in"
  post 'saml_login', to: "application#saml_login"
  post 'saml_callback', to: "application#saml_callback"
  get 'saml_metadata.xml', to: "application#metadata"
  post 'saml_logout', to:"application#saml_logout"
  
  get '/:slug', to: "petitions#by_slug" #this needs to go last, so that custom slugs can't break things
  post '/:slug', to: "petitions#sign" #this needs to go last, so that custom slugs can't break things
  delete '/:slug', to: "petitions#unsign" #this needs to go last, so that custom slugs can't break things

end
