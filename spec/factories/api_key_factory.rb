FactoryGirl.define do
  factory :api_key do
    user
    key { SecurityHelper.get_api_key }
  end
end