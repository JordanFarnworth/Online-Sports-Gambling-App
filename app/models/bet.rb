class Bet < ActiveRecord::Base
  belongs_to :lobby
  belongs_to :event_participant
  belongs_to :user
  belongs_to :monetary_transaction

  validates_presence_of :lobby, :event_participant, :user
  validates_numericality_of :bet_amount
  validates_inclusion_of :state, in: %w(active cancelled)
  validates :user, uniqueness: { scope: :lobby }
  validate :check_user_balance, on: :create

  scope :active, -> { where(state: :active) }

  before_validation do
    self.bet_amount ||= lobby.bet_amount
    self.state ||= :active
  end

  def check_user_balance
    errors.add(:bet_amount, 'is greater than available funds') if user.balance < bet_amount
  end

  before_create do
    self.monetary_transaction ||= MonetaryTransaction.create(user_id: user_id, transaction_type: 'bet', amount: -bet_amount)
  end

  def destroy
    monetary_transaction.destroy
    self.state = :cancelled
    save
  end
end
