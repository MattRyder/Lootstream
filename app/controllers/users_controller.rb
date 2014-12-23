class UsersController < ApplicationController

  # Redirect to the Twitch Auth endpoint
  def auth
    redirect_to twitch.getLink
  end

  def show
    twitch_data = twitch_auth(current_user.access_token).getYourUser
    @user_data = twitch_data[:body]

    @transactions = current_user.transactions
    @total_wagered = @transactions.map(&:amount).reduce(:+)
    @total_won = @transactions.select{|t| t.won }.map(&:amount).reduce(:+)
    @total_lost = @transactions.select{|t| !t.won }.map(&:amount).reduce(:+)
  end

end
