FactoryGirl.define do
  factory :event_participant do
    event
    name { SecureRandom.uuid }
  end

end
