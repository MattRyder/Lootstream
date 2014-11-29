class Channel < ActiveRecord::Base
 
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :balances
  has_many :wagers

  def self.parse_channels(streams)
    stream_data = []
    streams.each_with_index do |stream, i|
      channel = stream['channel']
      stream_data[i] = { 
        display_name: channel['display_name'],
        viewers: channel['viewers'],
        status: channel['status'],
        preview: stream['preview'],
        name: channel['name'],
        game: channel['game']
      }
    end
    stream_data
  end

end
