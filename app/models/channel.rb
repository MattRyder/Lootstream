class Channel < ActiveRecord::Base
 
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :balances
  has_many :wagers
end
