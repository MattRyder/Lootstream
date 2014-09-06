Rails.application.routes.draw do

  root "welcome#index"
  
  get 'welcome/index'
  get 'welcome/contact'

  resources :streams do
    resources :wagers, only: [:index, :new, :create]
  end

  post '/distribute_winnings' => "wagers#distribute_winnings", as: :wager_distribute

  resources :wagers, only: [:show, :edit, :update, :destroy] do
    get 'realtime' => 'wagers#process_realtime', as: :realtime
  end

  resources :games do
    get 'info' => 'games#game_info', as: :info, on: :member
  end

  devise_for :users, controllers: { registrations: 'registrations'}
  get 'users/auth' => 'user#auth', as: :auth_user

  post '/place_bet' => 'wagers#place_bet', as: :place_bet
end
