require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    before :each do
      group
    end

    it 'should receive a default state' do
      expect(@group.state).to eql 'active'
    end

    it 'should require a state to be valid' do
      @group.state = 'asdf'
      expect(@group.save).to be_falsey
    end

    it 'should require a name' do
      @group.name = ''
      expect(@group.save).to be_falsey
      @group.name = 'adsf'
      expect(@group.save).to be_truthy
    end
  end

  describe 'deletion' do
    it 'should delete group memberships on deletion' do
      user_with_group
      @group.destroy
      expect(@user.groups).to_not include(@group)
    end
  end
end
