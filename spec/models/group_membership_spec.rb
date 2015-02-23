require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe 'validations' do
    before :each do
      group_with_user
    end

    it 'should not allow duplicate memberships' do
      gm = @group.group_memberships.new user: @user
      expect(gm.save).to be_falsey
    end

    it 'should allow multiple memberships in the same group with different users' do
      u = user
      gm = @group.group_memberships.new user: u
      expect(gm.save).to be_truthy
    end

    it 'should receive a default state' do
      expect(@group_membership.state).to eql 'active'
    end

    it 'should require a state to be valid' do
      @group_membership.state = 'asdf'
      expect(@group_membership.save).to be_falsey
    end
  end
end
