class UserController < ApplicationController

  # Redirect to the Twitch Auth endpoint
  def auth
    redirect_to twitch.getLink
  end

end
