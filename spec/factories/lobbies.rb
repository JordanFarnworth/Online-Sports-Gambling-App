FactoryGirl.define do
  factory :lobby do
    group
    betting_begins_at { 1.week.ago }
    betting_ends_at { 1.week.from_now }
    state "active"
    event_day
  end

end
