class User < ActiveRecord::Base
  has_secure_password
  has_many :login_sessions

  scope :active, -> { where(state: :active) }
  scope :deleted, -> { where(state: :deleted) }

  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_presence_of :state

  before_validation :infer_values

  def infer_values
    self.state ||= :active
  end

  def active?
    state == 'active'
  end

  def destroy
    self.state = 'deleted'
    save
  end
end
