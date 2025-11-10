Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "prompts#new"
  # root "pages#_hero"
  root "pages#home"

  # auth
  get "/signup", to: "registrations#new", as: :signup
  post "/signup", to: "registrations#create"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  get  '/welcome',           to: 'welcome#show',     as: :welcome
  post '/welcome/complete',  to: 'welcome#complete', as: :complete_welcome

  get '/dashboard', to: 'dashboard#show', as: :dashboard

  get '/pricing', to: 'pages#pricing', as: :pricing

  post '/create-checkout-session', to: 'payments#create_checkout_session'
  post '/webhook', to: 'payments#webhook'

  # config/routes.rb
  get '/success', to: 'payments#success'
  get '/cancel',  to: 'payments#cancel'

  # Also map the .html URLs Stripe might use:
  get "/success", to: "payments#success", as: :payment_success
  get "/cancel", to: "payments#cancel", as: :payment_cancel

  get "/support", to: "pages#support", as: :support

  # Static pages
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"
  get "/impressum", to: "pages#impressum"

  resources :prompts, only: %i[index new create show]
  resources :prompt_templates, only: %i[index show create] do
    member do
      post :like
      post :execute
    end
    collection do
      get :categories
    end
  end  
end
