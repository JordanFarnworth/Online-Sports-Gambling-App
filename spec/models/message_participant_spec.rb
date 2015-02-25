require 'rails_helper'

RSpec.describe MessageParticipant, type: :model do
  describe 'validations' do
    before :each do
      message
      @message_participant = @message.message_participants.first
    end

    it 'should have a user' do
      @message_participant.user = nil
      expect(@message_participant.save).to be_falsey
    end

    it 'should have a message' do
      @message_participant.message = nil
      expect(@message_participant.save).to be_falsey
    end

    it 'should have a valid state' do
      @message_participant.state = 'asdf'
      expect(@message_participant.save).to be_falsey
    end
  end

  describe 'creation' do
    before :each do
      message
      @message_participant = @message.message_participants.first
    end

    it 'should receive an unread state by default' do
      expect(@message_participant.state).to eql 'unread'
    end

    it 'should mark a message as read' do
      @message_participant.mark_as_read!
      expect(@message_participant.state).to eql 'read'
    end
  end

  describe 'scoping' do
    before :each do
      message
    end

    it 'should return messages as a sender' do
      expect(@user.all_messages.as_sender.map(&:message)).to include(@message)
    end

    it 'should return messages as a recipient' do
      expect(@user.all_messages.as_recipient.map(&:message)).to_not include(@message)
      u = @message.message_participants.where.not(user_id: @message.sender_id).first.user
      expect(u.all_messages.as_recipient.map(&:message)).to include(@message)
    end
  end
end
