class ChannelsController < ApplicationController
  before_action :authenticate_user!

  def index
    if cookies.signed[:last_search].present?
      streams = twitch.search_streams(query: cookies.signed[:last_search])
      @streams = Channel.parse_channels(streams[:body]["streams"]) rescue nil
    end

    @streams = Channel.parse_channels(twitch.streams[:body]["streams"]) if @streams.blank?
    @search_title = cookies.signed[:last_search].present? ? "Results for: #{cookies.signed[:last_search]}" : "Popular Channels"

    games = twitch.top_games
    if games.present?
      @games = games[:body]["top"].map{ |game| game["game"]["name"] }
    end
  end

  def game_search
    streams = twitch.search_streams(query: params[:game_name])
    @streams = Channel.parse_channels(streams[:body]["streams"]) rescue nil

    respond_to do |format|
      if @streams.present?
        @search_title = params[:game_name].present? ? "Results for: #{params[:game_name]}" : "Popular Channels"
        cookies.signed[:last_search] = params[:game_name]
        format.js { render 'channelfield' }
      else
        format.js { render nothing: true }
      end
    end
  end

  def unset_search
    cookies.delete(:last_search) if cookies.signed[:last_search].present?
    redirect_to action: :index
  end


  def active_wager
    channel = Channel.find_by(name: params[:channel_id])
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
    stream = twitch.stream(params[:id])

    # Get some stuff about the current Twitch state
    channel = twitch.channel(params[:id])
    @channel_data = {
      status: channel[:body]['status'],
      game: channel[:body]['game'],
      background: channel[:body]['background'],
      views: channel[:body]["views"]
    }

    raise_404 if stream[:response] == 404

    # Load or save this channel:
    @channel = Channel.find_by(slug: params[:id])
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