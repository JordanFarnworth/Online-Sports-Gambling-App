class Transaction < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user
  validates_inclusion_of :state, in: %w(active cancelled)
  validates_inclusion_of :transaction_type, in: %w(payment withdrawal bet)
  validates_numericality_of :amount, greater_than: 0.0, less_than: 10000.0

  scope :active, -> { where(state: :active) }

  before_validation do
    self.state ||= :active
  end

  after_save do
    user.update_balance
  end

  def destroy
    self.state = :cancelled
    save
  end
end
