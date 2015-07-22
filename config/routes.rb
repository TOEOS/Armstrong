Rails.application.routes.draw do
  resources :events, only: [:index, :show]

  root 'static_pages#index'
end
