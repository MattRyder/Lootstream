class UsersController < ApplicationController

  # Redirect to the Twitch Auth endpoint
  def auth
    redirect_to twitch.getLink
  end

  def show
    twitch_data = twitch_auth(current_user.access_token).getYourUser
    @user_data = twitch_data[:body]
  end

end
