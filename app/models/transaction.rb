class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :wager_option
end
