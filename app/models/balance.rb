class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :stream

  def change(amount)
    self.update_attribute(balance: self.balance + amount)
  end
end
