Rails.application.routes.draw do
  root 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get '/api/study_time_records', to: 'api/study_time_records#show'
  delete 'log_out', to: 'sessions#destroy'
  resources :sessions, only: %i[create destroy]

  namespace :api, {format: 'json'} do
    namespace :discord, {format: 'json'} do
      resource :study_time_record, only: %i[create update]
    end
    resources :study_time_records, only: %i[create update]
  end
end
