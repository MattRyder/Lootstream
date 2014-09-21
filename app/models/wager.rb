class Wager < ActiveRecord::Base
  belongs_to :game
  belongs_to :channel

  has_many :wager_options

  accepts_nested_attributes_for :wager_options,
    reject_if: :all_blank, allow_destroy: true

  scope :active, -> { where(active: true) }

  def set_winner(option)
    byebug
    if option and option.wager == self
      self.winning_option = option.id
      self.suspend

      one_pct = self.total_amount_bet * 0.01
      p "--- REVENUE FOR STREAMER + BETSTREAM: $#{one_pct}"

      # give the option to the game, let it grab the transactions
      redeposits = self.game.calculate_winnings(self, option) || []

      redeposits.each do |uid, amt|
        user = User.find(uid)
        balance = user.channel_balance(channel)
        balance.change(amt)
      end

      status = "Wager suspended, winnings distributed"
    end
  end

  def suspend
    self.active = false
    self.suspended_at = DateTime.now
    self.save
  end

  def latest_transaction
    options = self.wager_options.map(&:id)
    Transaction.where(wager_option_id: options).last
  end

  def user_transaction(user_id)
    Transaction.find_by(user_id: user_id,
      wager_option_id: self.wager_options.map(&:id))
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
