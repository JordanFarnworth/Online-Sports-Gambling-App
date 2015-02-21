class MessageParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates_presence_of :user
  validates_presence_of :message
  validates_inclusion_of :state, in: %w(unread read deleted)

  scope :active, -> { where.not(state: :deleted) }
  scope :read, -> { where(state: :read) }
  scope :unread, -> { where(state: :unread) }

  before_validation do
    self.state ||= :unread
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
