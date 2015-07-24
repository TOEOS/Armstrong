Rails.application.routes.draw do
  resources :events, only: [:index, :show]

  namespace :api do
    resources :events, only:[] do
      resources :articles, only: [:index]
    end
  end
  root 'static_pages#index'
end
