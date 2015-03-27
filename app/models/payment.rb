class Payment < ActiveRecord::Base
  belongs_to :monetary_transaction
  belongs_to :user

  VALID_GATEWAYS = [
    'braintree'
  ]

  validates_presence_of :user
  validates_presence_of :uuid
  validates_inclusion_of :gateway, in: VALID_GATEWAYS
  validates_inclusion_of :state, in: %w(initiated processed failed)
  validates_numericality_of :amount, greater_than: 0.0, less_than: 10000.0, allow_nil: true

  serialize :parameters, Hash

  scope :failed, -> { where(state: :failed) }
  scope :processed, -> { where(state: :processed) }
  scope :initiated, -> { where(state: :initiated) }

  after_initialize do
    # Failsafe: Mark payments as failed if they remain in an initiated state for more than 2 days
    if created_at && created_at < 2.days.ago && state == 'initiated'
      self.state = 'failed'
      save
    end
  end

  before_validation do
    self.uuid ||= SecureRandom.uuid
    self.state ||= :initiated
    self.gateway ||= 'braintree'
  end

  after_save do
    if self.state == 'processed' && self.monetary_transaction.nil?
      t = MonetaryTransaction.create user: self.user, amount: self.amount, transaction_type: 'payment'
      self.update monetary_transaction: t
    end
  end

  def mark_as_processed!
    update state: 'processed'
  end

  def mark_as_failed!
    update state: 'failed'
  end
end
