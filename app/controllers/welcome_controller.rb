class WelcomeController < ApplicationController
  def index
    if params[:code]
      data = twitch.auth(params[:code])
      session[:access_token] = data[:body]["access_token"]
      user_data = twitch_auth(session[:access_token]).getYourUser
      @email = 'matt@mattryder.co.uk'# user_data[:body]['email']
    end
  end

  def contact
  end
end
