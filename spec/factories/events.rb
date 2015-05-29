FactoryGirl.define do
  factory :event do
    sport "NFL"
    event_starts_at "2015-05-24 14:43:38"
    code { SecureRandom.uuid }
  end

end
