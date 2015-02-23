class User < ActiveRecord::Base
  has_secure_password
  has_many :login_sessions
  has_many :api_keys
  has_many :group_memberships, -> { active }
  has_many :groups, -> { active }, through: :group_memberships
  has_many :message_participants, -> { active }
  has_many :messages, -> { active }, through: :message_participants

  scope :active, -> { where(state: :active) }
  scope :deleted, -> { where(state: :deleted) }

  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_presence_of :state

  before_validation :infer_values

  def infer_values
    self.state ||= :active
  end

  def all_messages
    message_participants.includes(:message).order(:created_at)
  end

  def active?
    state == 'active'
  end

  def destroy
    self.state = 'deleted'
    group_memberships.destroy_all
    save
  end
end
