Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /health.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "health" => "health#show", as: :health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"
      get "me", to: "me#show"

      resources :users do
        member do
          put :roles
        end
      end

      resources :roles do
        member do
          put :permissions
        end
      end

      resources :apps, only: %i[index show update]
      resources :permissions
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
