require 'sidekiq/web'

Rails.application.routes.draw do
  resources :events, only: [:index, :show]

  namespace :api do
    resources :events, only:[] do
      resources :articles, only: [:index]
    end
  end
  root 'static_pages#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
end
