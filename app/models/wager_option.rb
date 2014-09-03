class WagerOption < ActiveRecord::Base
  belongs_to :wager
  has_many :transactions
end
