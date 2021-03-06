require 'rails_helper'

RSpec.describe RoleMembership, type: :model do
  describe 'validations' do
    before :each do
      user_with_role
    end

    it 'should recieve a default state' do
      expect(@role_membership.state).to eql 'active'
    end

    it 'should require a role membership to be unique' do
      rp = RoleMembership.new role: @role, user: @user
      expect(rp.save).to be_falsey
    end
  end

  describe 'deletion' do
    before :each do
      user_with_role
    end

    it 'should mark a role membership as deleted' do
      @role_membership.destroy
      expect(@role_membership.state).to eql 'deleted'
    end
  end
end
