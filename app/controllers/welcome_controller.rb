class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to channels_path 
    elsif params[:code]
      data = twitch.auth(params[:code])
      session[:access_token] = data[:body]["access_token"]
      user_data = twitch_auth(session[:access_token]).your_user
      @email = user_data[:body]['email']
    end
  end

  def contact
  end
end
