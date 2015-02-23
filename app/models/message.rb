class ParticipantValidator < ActiveModel::Validator
  def validate(message)
    unless message.message_participants.any? { |mp| mp.user_id != message.sender_id }
      message.errors[:base] << 'Messages need a recipient'
    end
  end
end

class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  has_many :message_participants, -> { active }, inverse_of: :message
  has_many :users, -> { active }, through: :message_participants

  validates_presence_of :sender_id
  validates :subject, presence: true, length: { minimum: 3 }
  validates :body, presence: true, length: { minimum: 3 }
  validates_inclusion_of :state, in: %w(active deleted)
  validates_with ParticipantValidator, on: :create

  scope :active, -> { where(state: :active) }
  scope :include_participants, -> { includes(:message_participants) }

  accepts_nested_attributes_for :message_participants

  before_validation do
    self.state ||= :active
  end

  after_create do
    unless users.where(id: sender_id).exists?
      message_participants.create user: sender
    end
  end

  def participants
    message_participants.pluck(:user_id)
  end

  def active?
    state == 'active'
  end
end
