require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'validations' do
    before :each do
      message
    end

    it 'should have a sender' do
      @message.sender = nil
      expect(@message.save).to be_falsey
    end
  end

  describe 'creation' do
    it 'should add the sender as a participant' do
      message
      expect(@message.users).to include(@user)
    end

    it 'should receive a default state' do
      message
      expect(@message.state).to eql 'active'
    end
  end
end
