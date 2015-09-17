class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel

  validates :balance, numericality: { greater_than: 0 }

  def change(amount)
    self.update_attributes(balance: self.balance + amount)
  end

  def display_value
    self.balance.round(2)
  end
end
