Rails.application.routes.draw do
  resources :events, only: [:index]

  root 'static_pages#index'
end
