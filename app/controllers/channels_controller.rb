class ChannelsController < ApplicationController
  before_action :authenticate_user!

  def index
    @streams = Channel.parse_channels(twitch.getStreams[:body]["streams"])

    games = twitch.getTopGames()
    if games.present?
      @games = games[:body]["top"].map{ |game| game["game"]["name"] }
    end
  end

  def game_search
    streams = twitch.searchStreams(query: params[:game_name])
    @streams = Channel.parse_channels(streams[:body]["streams"])

    respond_to do |format|
      format.js { render 'channelfield' }
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

  private

  def channel_not_found
    raise ActionController::RoutingError.new('Channel not found!')
  end
end