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

  def won
    self.wager.winning_option == self.id
  end

  def calculate_odds
    wager = self.wager

    amt_option = self.amount_bet.to_i
    total_less_option = (wager.total_amount_bet.to_i - amt_option)

    #amt_option = 1 if amt_option < 1
    #total_less_option = 1 if total_less_option < 1

    div_factor = total_less_option.gcd(amt_option)

    while div_factor > 1
      total_less_option /= div_factor
      amt_option /= div_factor
      div_factor = total_less_option.gcd(amt_option)
    end

    "#{amt_option} / #{total_less_option}"
  end
  
end
