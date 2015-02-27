require 'rails_helper'

RSpec.describe ApiKey, :type => :model do
  describe 'creation' do
    before(:each) do
      user
    end

    it 'should be linked to a user' do
      a = ApiKey.new key: SecurityHelper.get_api_key
      expect(a.save).to be_falsey
      a.user = @user
      expect(a.save).to be_truthy
    end

    describe 'existing key' do
      before(:each) do
        api_key
      end

      it 'should hash the key' do
        expect(@api_key.key).to_not eql @key
      end

      it 'should provide a key hint' do
        expect(@api_key.key_hint).to eql @key[0, 6]
      end

      it 'should set a default expiration date' do
        expect(@api_key.expires_at).to be_between(4.years.from_now, 6.years.from_now)
      end
    end
  end

  describe 'expiration' do
    before :each do
      user
      api_key
    end

    it 'should expire an API key when being deleted' do
      @api_key.destroy
      expect(@api_key.expired?).to be_truthy
    end
  end
end