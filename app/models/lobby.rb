class LobbyDateValidator < ActiveModel::Validator
  def validate(lobby)
    if lobby.betting_begins_at && lobby.betting_ends_at && lobby.betting_begins_at > lobby.betting_ends_at
      lobby.errors[:betting_begins_at] << 'Start time cannot come after end time'
    end
  end
end

class Lobby < ActiveRecord::Base
  belongs_to :group
  belongs_to :event_day

  validates_inclusion_of :state, in: %w(active completed deleted)
  validates_with LobbyDateValidator
  validates_presence_of :event_day

  scope :active, -> { where(state: :active) }
  scope :completed, -> { where(state: :completed) }
  scope :allows_betting, -> { active.where('betting_begins_at < ? AND betting_ends_at > ?', Time.now, Time.now) }

  serialize :settings, Hash

  default_settings = {

  }

  after_initialize do
    default_settings.each do |k, v|
      self.settings[k] ||= v
    end
  end

  before_validation do
    self.state ||= :active
  end

  def destroy
    self.state = :deleted
    save
  end

  def allow_bets?
    return false if betting_begins_at && betting_begins_at > Time.now
    return false if betting_ends_at && betting_ends_at < Time.now
    true
  end
end
