Rails.application.routes.draw do
  root 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'log_out', to: 'sessions#destroy'
  resources :sessions, only: %i[create destroy]

  namespace :api, {format: 'json'} do
    resources :study_time_records, only: %i[create]
  end
end
