class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :wager_option

  def display_amount
    int_amt, flt_amt = self.amount.to_i, self.amount.to_f
    int_amt == flt_amt ? int_amt : flt_amt
  end

  def won
    self.wager_option.won
  end

end
