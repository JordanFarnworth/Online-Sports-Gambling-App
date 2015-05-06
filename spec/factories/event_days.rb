def get_sport
  %w(nfl nba mlb)[rand(3)]
end

FactoryGirl.define do
  factory :event_day do
    event_day_tag { EventDay.infer_date_tag(get_sport, Time.now) }
  end
end
