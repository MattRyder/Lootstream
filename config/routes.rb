Rails.application.routes.draw do

  root "welcome#index"

  constraints(SubdomainRouter) do
    get '/' => 'channels#show', as: :subdomain_show
  end
  
  get 'welcome/index'
  get 'welcome/contact'

  namespace :api, path: "", constraints: {subdomain: 'api'}, defaults: {format: 'json'} do
    namespace :v1 do
      get '/channel'        => 'channel#channel'
      post '/create_wager'  => 'wagers#create_wager'
      post '/set_winner'    => 'wagers#set_winner'
    end
  end

  resources :channels do
    resources :wagers, only: [:index, :new, :create] do
      post 'setup'     => 'wagers#new_wager_setup', as: :setup,        on: :collection
    end

    get  'active'       => 'channels#active_wager', as: :active
    get 'game_search'  => 'channels#game_search' , as: :game_search,  on: :collection
    post 'unset_search' => 'channels#unset_search', as: :unset_search, on: :collection
  end

  # THESE NEED NESTING UNDER APPROPRIATE RESOURCES:
  post '/distribute_winnings' => "wagers#distribute_winnings", as: :wager_distribute
  post '/place_bet' => 'wagers#place_bet', as: :place_bet

  resources :wagers, only: [:show, :edit, :update, :destroy] do
    get 'realtime'    => 'wagers#process_realtime', as: :realtime
    get 'render_form' => 'wagers#render_form',      as: :render_form, on: :collection
  end

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
