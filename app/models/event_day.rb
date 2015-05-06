class EventDay < ActiveRecord::Base
  has_many :lobbies

  TAG_REGEX = /\A([a-z]+)_(\d{4})_(\d{2})_(\d{2})\z/

  validates_uniqueness_of :event_day_tag
  validates_format_of :event_day_tag, with: TAG_REGEX

  before_save do
    self.sport ||= event_day_tag.match(TAG_REGEX)[1]
  end

  def self.for_sport_and_date(sport, date = Time.now)
    EventDay.find_by_event_day_tag infer_date_tag(sport, date)
  end

  def self.infer_date_tag(sport, date = Time.now)
    sport + '_' + Time.now.strftime('%Y_%m_%d')
  end

  def date
    match = event_day_tag.match(TAG_REGEX)
    Time.new(match[2], match[3], match[4]) rescue nil
  end
end
