FactoryGirl.define do
  factory :user do
    username { SecureRandom.uuid }
    display_name { SecureRandom.uuid }
    email { SecureRandom.uuid << '@test.com' }
    password 'password' # Short, simple, easy to remember for tests
    balance { SecureRandom.random_number(100) + 100 }
  end
end
