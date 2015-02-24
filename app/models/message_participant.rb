class MessageParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :message, inverse_of: :message_participants

  validates_each :user, :message do |record, attr, value|
    record.errors.add attr, 'is not valid' unless value && value.active?
  end
  validates_inclusion_of :state, in: %w(unread read deleted)
  validates_inclusion_of :user_type, in: %w(sender recipient)
  validates :message_id, uniqueness: { scope: :user_id }

  scope :active, -> { where.not(state: :deleted) }
  scope :read, -> { where(state: :read) }
  scope :unread, -> { where(state: :unread) }
  scope :as_sender, -> { where(user_type: :sender) }
  scope :as_recipient, -> { where(user_type: :recipient) }

  before_validation do
    self.state ||= :unread
    self.user_type ||= :recipient
  end

  def mark_as_read
    self.state = :read
  end

  def mark_as_read!
    mark_as_read
    save
  end

  def destroy
    self.state = :deleted
    save
  end
end
