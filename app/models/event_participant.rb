class EventParticipant < ActiveRecord::Base
  belongs_to :event

  validates_presence_of :event, :name, :code
  validates_numericality_of :outcome

  scope :ordered, -> { order(outcome: :desc) }

  before_validation do
    self.code ||= name
    self.outcome ||= 0.0
  end
end
