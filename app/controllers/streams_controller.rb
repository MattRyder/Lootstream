class StreamsController < ApplicationController
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
        name: channel['name']
      }
    end
  end
  def show
    stream = twitch.getStream(params[:id])

    if stream
      # get the stream object from the database for this:
      @stream = Stream.find_or_create_by!(name: params[:id])
      @balance = current_user.stream_balance(@stream)
      @wager = Wager.find_by(stream: @stream, active: true)

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
  end
end
