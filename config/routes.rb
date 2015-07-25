require 'sidekiq/web'

Rails.application.routes.draw do
  resources :events, only: [:index, :show] do
    patch :create_message
  end

  namespace :api do
    resources :events, only: [] do
      resources :articles, only: [:index]
    end
  end

  root 'events#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
end
