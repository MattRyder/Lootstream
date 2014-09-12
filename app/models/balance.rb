class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :stream

  validates :balance, numericality: { greater_than: 0 }

  def change(amount)
    self.update_attributes(balance: self.balance + amount)
  end
end
