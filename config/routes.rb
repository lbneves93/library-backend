Rails.application.routes.draw do
  get "dashboard/report"
  get "borrows/update"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # Books resource routes
  resources :books do
    member do
      post :borrow
    end
  end
  
  # Borrows resource routes
  resources :borrows, only: [:update]

  # Dashboard route
  get 'dashboard', to: 'dashboard#report'

  # Defines the root path route ("/")
  #root"#index"
end
