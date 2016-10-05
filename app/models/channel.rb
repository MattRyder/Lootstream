class Channel < ActiveRecord::Base

  acts_as_url :name, url_attribute: :slug

  has_many :balances
  has_many :wagers

  def self.parse_channels(streams)
    stream_data = []
    streams.to_a.each_with_index do |stream, i|
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

  def to_param
    name
  end

end
