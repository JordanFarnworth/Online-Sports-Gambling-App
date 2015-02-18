class User < ActiveRecord::Base
  has_secure_password
  has_many :login_sessions

  scope :active, -> { where(state: :active) }
  scope :deleted, -> { where(state: :deleted) }

  before_save :infer_values

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
