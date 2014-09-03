class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :stream

  def change(amount)
    self.balance = self.balance + amount
    self.save!
  end
end
