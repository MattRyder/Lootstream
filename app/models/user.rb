class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Associations
  has_many :balances
  has_many :transactions
  has_one :channel

  before_create :gen_token

  acts_as_url :username, url_attribute: :slug

  # Validation
  #validates_presence_of :access_token

  validates_format_of :email, :with  => Devise.email_regexp,
    :if => :email_changed?

  def channel_balance(channel)
    balance = self.balances.find_or_create_by(channel: channel) do |s|
      s.balance = 100
    end
  end

  def to_param
    username
  end

private
  def gen_token
    return if access_token.present?

    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: self.access_token)
  end

end
