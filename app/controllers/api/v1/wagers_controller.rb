class API::V1::WagersController < API::V1::ApiController

  before_filter :authenticate

  # GET /channel/(/:id)/wager
  # Returns the channel's current wager
  def wager
    wager = @user.channel.wager
    render json: @user.channel.to_json(except: [:id])
  end

  # GET /channel/(/:id)/create_wager
  def create_wager
    if params[:wager].present?
      wager = Wager.new(wager_params)
      wager.channel_id = @user.channel.id

      if wager.save
        render json: { message: 'Saved Wager successfully.' }
      else
        render json: { message: 'Failed to save Wager, is the data correct?.' }
      end

    else
      render json: { message: 'Your request was malformed or incomplete.'}
    end
  end


private

  # Use callbacks to share common setup or constraints between actions.
  def set_wager
    @wager = Wager.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wager_params
    params.require(:wager).permit(:game_id, :channel_id, :question, :min_amount, :max_amount,
      wager_options_attributes: [:id, :text, :_destroy])
  end

end