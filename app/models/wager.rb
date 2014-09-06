class Wager < ActiveRecord::Base
  belongs_to :game
  belongs_to :stream

  has_many :wager_options

  accepts_nested_attributes_for :wager_options,
    reject_if: :all_blank, allow_destroy: true

  def suspend
    self.active = false
    self.suspended_at = DateTime.now
    self.save
  end

  def latest_transaction
    options = self.wager_options.map(&:id)
    Transaction.where(wager_option_id: options).last
  end


  # Return the total amount put up for this wager
  def total_amount_bet
    total_amount = 0
    self.wager_options.each do |wo|
      total_amount +=  wo.amount_bet
    end
    total_amount
  end

  # Return a general overview of what has been bet,
  # how much, etc
  def transaction_data
    transactions = []
    self.wager_options.each do |wo|
      option_data = {}

      transactions << {
        option: wo,
        transactions: wo.transactions,
        total_amount: wo.amount_bet,
        count: wo.transactions.count
      }
    end
    transactions
  end
    
end
