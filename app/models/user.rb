class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Associations
  has_many :balances
  has_many :transactions

  # Validation
  #validates_presence_of :access_token

  validates_format_of :email, :with  => Devise.email_regexp,
    :if => :email_changed?

  def stream_balance(stream)
    balance = self.balances.find_by(stream: stream)
    balance = self.balances.create!(stream: stream, balance: 100) unless balance

    return balance
  end
end
