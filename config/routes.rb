Rails.application.routes.draw do
  resources :petitions
  resources :users
  devise_for :users

  root to: "application#index"
  get 'logged_in', to: "application#logged_in"
  post 'saml_login', to: "application#saml_login"
  post 'saml_callback', to: "application#saml_callback"
  get 'saml_metadata.xml', to: "application#metadata"
  
  get 'admin/user_list', to: "admin#user_list"
end
