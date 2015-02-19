require 'rails_helper'

RSpec.describe LoginSession, type: :model do
  before :all do
    user
  end

  describe 'creation' do
    it 'should create a login session' do
      ls = @user.login_sessions.new key: SecurityHelper.get_session_key
      ls.key = SecurityHelper.sha_hash(ls.key)
      expect(ls.save).to be_truthy
    end
  end

  describe 'expiration' do
    before :all do
      login_session
    end

    it 'should not be expired when initially created' do
      expect(@login_session.expired?).to be_falsey
    end

    it 'should be expired when destroyed' do
      @login_session.destroy
      expect(@login_session.expired?).to be_truthy
    end
  end
end
