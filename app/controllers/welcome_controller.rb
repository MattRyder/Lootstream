class WelcomeController < ApplicationController
  def index
    if params[:code]
      data = twitch.auth(params[:code])
      session[:access_token] = data[:body]["access_token"]
      user_data = twitch_auth(session[:access_token]).getYourUser
      @email = user_data[:body]['email']
    end
    render layout: 'homepage'
  end

  def contact
  end
end
