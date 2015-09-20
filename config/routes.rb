Rails.application.routes.draw do
  
  match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ]

  root "welcome#index"

  constraints(SubdomainRouter) do
    get '/' => 'channels#show', as: :subdomain_show
  end
  
  get 'welcome/index'
  get 'welcome/contact'

  namespace :api, path: "", constraints: {subdomain: 'api'}, defaults: {format: 'json'} do
    namespace :v1 do
      get '/channel'        => 'channel#show'
      post '/create_wager'  => 'wagers#create_wager'
      post '/set_winner'    => 'wagers#set_winner'
    end
  end

  resources :channels do
    resources :wagers do
      get 'realtime'    => 'wagers#process_realtime', as: :realtime
      get 'render_form' => 'wagers#render_form',      as: :render_form, on: :collection
      post 'setup'      => 'wagers#new_wager_setup',  as: :setup,       on: :collection
      post 'winner/:wager_option_id'     => 'wagers#distribute_winnings', as: :winner, on: :member
    end

    get  'active'       => 'channels#active_wager', as: :active
    get 'game_search'  => 'channels#game_search' , as: :game_search,  on: :collection
    post 'unset_search' => 'channels#unset_search', as: :unset_search, on: :collection
  end

  # THESE NEED NESTING UNDER APPROPRIATE RESOURCES:
  post '/place_bet' => 'wagers#place_bet', as: :place_bet

  resources :games do
    get 'info' => 'games#game_info', as: :info, on: :member
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users, only: [:show] do
    get  "auth"    => 'users#auth',         as: :auth,   on: :collection
    post "api_key" => "users#generate_key", as: :api_key
  end

end
