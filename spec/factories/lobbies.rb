FactoryGirl.define do
  factory :lobby do
    group
    bet_amount 5.0
    betting_begins_at { 1.week.ago }
    betting_ends_at { 1.week.from_now }
    state "active"
  end

end
