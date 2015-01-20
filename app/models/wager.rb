class Wager < ActiveRecord::Base
  belongs_to :game
  belongs_to :channel

  has_many :wager_options

  accepts_nested_attributes_for :wager_options,
    reject_if: :all_blank, allow_destroy: true

  validates :game, :question, :min_amount, :max_amount, presence: true

  scope :active, -> { find_by(active: true) }

  def set_winner(option)

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

  def place_bet(wager_option_id, current_user, amount)
    amount = amount.to_i
    wager = WagerOption.find(wager_option_id).wager
    bal = current_user.channel_balance(wager.channel)

    if wager.blank?
      error_message = "Cannot find wager for that option!"
    elsif amount < wager.min_amount
      error_message = "Amount must be above $#{wager.min_amount.to_i}"
    elsif amount > wager.max_amount
      error_message = "Amount must be under $#{wager.max_amount.to_i}"
    elsif bal.balance - amount < 0
      error_message = "Not enough balance!"
    end

    if !error_message
      transaction = Transaction.create(
        amount: amount,
        wager_option_id: wager_option_id,
        user_id: current_user.id)

      bal.change(-amount)
      return { success: true, new_balance: bal.balance }
    else
      return { success: false, error_message: error_message}
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
