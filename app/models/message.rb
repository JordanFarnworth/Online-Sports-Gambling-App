class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  has_many :message_participants, -> { active }
  has_many :users, -> { active }, through: :message_participants

  validates_presence_of :sender_id
  validates :subject, presence: true, length: { minimum: 3 }
  validates :body, presence: true, length: { minimum: 3 }
  validates_inclusion_of :state, in: %w(active deleted)

  scope :active, -> { where(state: :active) }

  before_validation do
    self.state ||= :active
  end

  after_create do
    unless users.where(id: sender_id).exists?
      message_participants.create user: sender
    end
  end
end
