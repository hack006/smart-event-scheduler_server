Rails.application.routes.draw do
  resources :events, only: [:create, :update, :destroy] do
    collection do
      get 'my' => 'events#my_events'
    end
  end

  resources :activity_details

  resources :time_details

  resources :slots

  resources :availabilities

  resources :preferences

  resources :participants

  devise_for :users
end
