Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /health.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "health" => "health#show", as: :health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
