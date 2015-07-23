Rails.application.routes.draw do
  resources :events, only: [:index]

  root 'static_pages#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
end
