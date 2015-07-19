require 'sidekiq/web'

Rails.application.routes.draw do
  resources :events, only: [:index]

  root 'static_pages#index'
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
end
