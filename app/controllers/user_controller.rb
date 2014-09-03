class UserController < ApplicationController
  def auth
    redirect_to twitch.getLink
  end
end
