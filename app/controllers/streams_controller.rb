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
      @wager = Wager.where(stream: @stream).take
    end
  end
end
