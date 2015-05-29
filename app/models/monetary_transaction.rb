class MonetaryTransaction < ActiveRecord::Base
  belongs_to :user
  has_one :payment
  has_one :bet

  validates_presence_of :user
  validates_inclusion_of :state, in: %w(active cancelled)
  validates_inclusion_of :transaction_type, in: %w(payment withdrawal bet award)
  validates_numericality_of :amount, greater_than: -10000.0, less_than: 0.0, if: '%w(withdrawl bet).include?(transaction_type)'
  validates_numericality_of :amount, greater_than: 0.0, less_than: 10000.0, if: '%w(payment award).include?(transaction_type)'

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

  def linked_transaction
    case transaction_type
    when 'payment'
      payment
    when 'bet'
      bet
    end
  end
end
