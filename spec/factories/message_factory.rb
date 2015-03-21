FactoryGirl.define do
  factory :message do
    subject { SecureRandom.uuid }
    body { SecureRandom.uuid }

    association :sender, factory: :user
    after :build do |message|
      if message.message_participants.empty?
        message.message_participants.build user_id: create(:user).id
      end
    end
  end
end