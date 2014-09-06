class WagerOption < ActiveRecord::Base
  belongs_to :wager
  has_many :transactions

  def amount_bet
    if self.transactions.count > 0
      self.transactions.map(&:amount).reduce(:+)
    else
      0
    end
  end
  
end
