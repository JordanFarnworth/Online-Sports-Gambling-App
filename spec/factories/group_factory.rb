FactoryGirl.define do
  factory :group do
    name { SecureRandom.uuid }
  end
end