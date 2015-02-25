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
    unless message_participants.where(user_id: sender_id, user_type: :sender).exists?
      message_participants.create user: sender, state: :read, user_type: :sender
    end
  end

  def participants(with_sender = false)
    mp = message_participants.map { |m| { user_id: m.user_id, display_name: m.user.display_name } }
    unless with_sender
      mp.reject! { |m| m[:user_id] == sender_id }
    end
    mp
  end

  def active?
    state == 'active'
  end
end
