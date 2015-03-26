FactoryGirl.define do
  factory :login_session do
    user
    key { SecurityHelper.get_session_key }
  end
end