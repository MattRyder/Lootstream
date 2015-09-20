class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  # Redirect to the Twitch Auth endpoint
  def auth
    redirect_to twitch.link
  end

  def show
    twitch_data = twitch_auth(current_user.access_token).your_user
    @user_data = twitch_data[:body]

    @transactions = current_user.transactions
    if @transactions.present?
      @total_wagered = @transactions.map(&:amount).reduce(:+)
      @total_won = @transactions.select{|t| t.won }.map(&:amount).reduce(:+) rescue 0
      @total_lost = @transactions.select{|t| !t.won }.map(&:amount).reduce(:+) rescue 0

      if (@total_lost.present? && @total_won.present?)
        @roi =  (@total_won > @total_lost) ? (@total_won / @total_lost) : (@total_lost / @total_won)
        @roi = @roi.round(2)
      else
        @roi = "N/A"
      end
    else
      @total_wagered = @total_won = @total_lost = 0
    end
  end

  # Generates an API Key for the current_user
  def generate_key
    current_user.api_key = SecureRandom.hex(32)
    respond_to do |format|
      format.json { render json: {saved: current_user.save, key: current_user.api_key} }
    end
  end

private

  def set_user
    @user = User.find_by(slug: params[:id])
    render file: "public/404.html", status: :not_found if @user.blank?
  end


end
