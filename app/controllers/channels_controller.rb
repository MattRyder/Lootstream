class ChannelsController < ApplicationController
  before_action :authenticate_user!

  def index
    @streams = []
    streams = twitch.getStreams[:body]["streams"]

    streams.each_with_index do |stream, i|
      channel = stream['channel']
      @streams[i] = { 
        display_name: channel['display_name'],
        viewers: channel['viewers'],
        status: channel['status'],
        preview: stream['preview'],
        name: channel['name'],
        game: channel['game']
      }
    end
  end

  def active_wager
    channel = Channel.find(params[:channel_id])
    @wager = Wager.find_by(channel_id: channel.id, active: true)
    respond_to do |format|
      if @wager.nil? || @wager.id.to_s == params[:current_wager]
        format.js { render nothing: true }
      else
        format.js { render 'betfield' }
      end
    end
  end

  def show
    Channel.find_or_create_by(name: params[:id])
    stream = twitch.getStream(params[:id])

    # Get some stuff about the current Twitch state
    channel = twitch.getChannel(params[:id])
    @channel_data = {
      status: channel[:body]['status'],
      game: channel[:body]['game'],
      background: channel[:body]['background']
    }

    render channel_not_found if stream[:response] == 404

    # Load or save this channel:
    @channel = Channel.friendly.find(params[:id])
    @balance = current_user.channel_balance(@channel)
    @wager = Wager.where(channel: @channel).last
    if request.env['HTTP_USER_AGENT'] && request.env['HTTP_USER_AGENT'] [/(Mobile\/.+Safari)|(AppleWebKit\/.+Mobile)/]
      @player = 'hls_player'
    else
      @player = 'flash_player'
    end

    if @wager
      opt_ids = @wager.wager_options.map(&:id)
      @transaction = Transaction.find_by(user_id: current_user, wager_option_id: opt_ids)
    end
  end

  def channel_not_found
    raise ActionController::RoutingError.new('Channel not found!')
  end

end
