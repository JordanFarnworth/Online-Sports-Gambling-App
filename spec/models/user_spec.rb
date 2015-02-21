require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creation' do
    before(:each) do
      user
    end

    it 'should check validations' do
      uuid = SecureRandom.uuid
      u = User.new username: @user.username, display_name: uuid, email: uuid + '@test.com'

      # Check username uniqueness
      expect(u.save).to be_falsey

      # Check email uniqueness
      u.username = uuid
      u.email = @user.email
      expect(u.save).to be_falsey

      # Check email format
      u.email = uuid
      expect(u.save).to be_falsey

      # Check password matching
      u.email = uuid + '@test.com'
      u.password = uuid
      u.password_confirmation = uuid + '1'
      expect(u.save).to be_falsey

      u.password_confirmation = uuid
      expect(u.save).to be_truthy
    end

    it 'should correctly compare passwords' do
      pass = '1234'
      @user.update password: pass, password_confirmation: pass
      expect(@user.try(:authenticate, pass)).to be_truthy
      expect(@user.try(:authenticate, 'abcd')).to be_falsey
    end

    it 'should receive a default state' do
      expect(@user.state).to eql 'active'
    end
  end

  describe 'messages' do
    before :each do
      message
    end

    it 'should only return messages that haven\'t been deleted' do
      mp = @message.message_participants.find_by_user_id @user.id
      mp.destroy
      expect(@user.messages).to_not include(@message)
    end
  end
end
