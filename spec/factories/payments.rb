FactoryGirl.define do
  factory :payment do
    user
    gateway 'braintree'
    amount { SecureRandom.random_number(100) + 1 }
  end
end
