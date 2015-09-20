class API::V1::ChannelController < API::V1::ApiController

  before_filter :authenticate

  # GET /channel
  # Returns the user's channel
  def show
    respond_with @user.channel.to_json(except: [:user_id, :slug])
  end

end