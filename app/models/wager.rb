class Wager < ActiveRecord::Base
  belongs_to :game
  belongs_to :stream

  has_many :wager_options

  accepts_nested_attributes_for :wager_options,
    reject_if: :all_blank, allow_destroy: true

  # Return the total amount put up for this wager
  def total_amount_bet
    total_amount = 0
    self.wager_options.each do |wo|
      wo_trans = Transaction.where(wager_option_id: wo)
      total_amount += wo_trans.map(&:amount).reduce(:+)
    end
    total_amount
  end

  # Return a general overview of what has been bet,
  # how much, etc
  def transaction_data
    transactions = []
    self.wager_options.each do |wo|
      option_data = {}

      wo_transactions = Transaction.where(wager_option_id: wo)
      transactions << {
        option: wo,
        transactions: wo_transactions,
        total_amount: wo_transactions.map(&:amount).reduce(:+),
        count: wo_transactions.count
      }
    end
    transactions
  end
    
end
