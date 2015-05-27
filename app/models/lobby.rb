class LobbyDateValidator < ActiveModel::Validator
  def validate(lobby)
    if lobby.betting_begins_at && lobby.betting_ends_at && lobby.betting_begins_at > lobby.betting_ends_at
      lobby.errors[:betting_begins_at] << 'Start time cannot come after end time'
    end
  end
end

class Lobby < ActiveRecord::Base
  belongs_to :group
  belongs_to :event
  has_many :bets

  validates_inclusion_of :state, in: %w(active completed deleted)
  validates_with LobbyDateValidator
  validates_numericality_of :bet_amount

  scope :active, -> { where(state: :active) }
  scope :completed, -> { where(state: :completed) }
  scope :allows_betting, -> { where('betting_begins_at < ? AND betting_ends_at > ?', Time.now, Time.now) }

  serialize :settings, Hash

  default_settings = {
    maximum_bet: 10.0,
    minimum_bet: 1.0
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
    bets.destroy_all
    self.state = :deleted
    save
  end

  def allow_bets?
    return false if betting_begins_at && betting_begins_at > Time.now
    return false if betting_ends_at && betting_ends_at < Time.now
    true
  end
end
