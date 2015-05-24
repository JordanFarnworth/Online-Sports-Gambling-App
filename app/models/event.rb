class Event < ActiveRecord::Base
  has_many :lobbies, dependent: :destroy

  validates_inclusion_of :state, in: %w(not_started in_progress completed)
  validates_presence_of :event_starts_at
  validates_presence_of :sport

  scope :not_started, -> { where(state: :not_started) }
  scope :in_progress, -> { where(state: :in_progress) }
  scope :completed, -> { where(state: :completed) }
  scope :on_date, -> (date) { where('event_starts_at >= ? AND event_starts_at <= ?',
                              date.beginning_of_day, date.end_of_day) }

  before_validation do
    self.state ||= :not_started
  end

  def start
    update state: :in_progress
  end

  def complete
    update state: :completed
  end
end
