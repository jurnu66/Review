Rottenpotatoes::Application.routes.draw do
  resources :movies do
    resources :reviews, only: [:new, :create, :index]
  end

  # Authentication Routes
  get 'signup', to: 'users#new'
  post 'users', to: 'users#create'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # map '/' to be a redirect to '/movies'
  root 'movies#index'
end