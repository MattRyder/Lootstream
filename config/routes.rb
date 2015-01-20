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
    resources :wagers, only: [:index, :new, :create]
    get 'active'        => 'channels#active_wager',     as: :active
    post 'game_search'  => 'channels#game_search',  as: :game_search, on: :collection
    post 'unset_search' => 'channels#unset_search', as: :unset_search, on: :collection
  end

  post '/distribute_winnings' => "wagers#distribute_winnings", as: :wager_distribute

  resources :wagers, only: [:show, :edit, :update, :destroy] do
    get 'realtime'    => 'wagers#process_realtime', as: :realtime
    get 'render_form' => 'wagers#render_form',      as: :render_form, on: :collection
  end

  resources :games do
    get 'info' => 'games#game_info', as: :info, on: :member
  end

  resources :users, only: [:show] do
    get 'auth' => 'users#auth', as: :auth, on: :collection
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
  }

  post '/place_bet' => 'wagers#place_bet', as: :place_bet
end
