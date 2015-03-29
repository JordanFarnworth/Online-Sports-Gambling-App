class User < ActiveRecord::Base
  has_secure_password
  has_many :login_sessions
  has_many :api_keys
  has_many :group_memberships, -> { active }
  has_many :groups, -> { active }, through: :group_memberships
  has_many :message_participants, -> { active }
  has_many :messages, -> { active }, through: :message_participants
  has_many :role_memberships, -> { active }
  has_many :roles, -> { active }, through: :role_memberships
  has_many :monetary_transactions
  has_many :payments
  has_many :page_views

  scope :active, -> { where(state: :active) }
  scope :deleted, -> { where(state: :deleted) }

  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_presence_of :state
  validates_uniqueness_of :braintree_customer_id

  before_validation :infer_values

  def infer_values
    self.state ||= :active
    self.braintree_customer_id ||= SecureRandom.hex 8
  end

  def all_messages
    message_participants.includes(:message).order(created_at: :desc)
  end

  def active?
    state == 'active'
  end

  def destroy
    self.state = 'deleted'
    group_memberships.destroy_all
    role_memberships.destroy_all
    save
  end

  def has_permission?(perm)
    roles.any? { |r| r.permissions[perm] }
  end

  def update_balance
    self.update balance: monetary_transactions.active.sum(:amount).round(2)
  end
end
