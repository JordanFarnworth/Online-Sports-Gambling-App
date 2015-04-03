require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    before :each do
      @group = create :group
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

    it 'should receive default settings' do
      settings = @group.settings
      expect(settings[:max_users]).to eql 10
      expect(settings[:availability]).to eql 'public'
      expect(settings[:lobbies]).to eql 20
      expect(settings[:description]).to_not be_nil
    end
  end

  describe 'deletion' do
    before :each do
      user_with_group
    end

    it 'should delete group memberships on deletion' do
      @group.destroy
      expect(@user.groups).to_not include(@group)
    end

    it 'should mark a group as deleted' do
      @group.destroy
      expect(@group.reload.state).to eql 'deleted'
    end
  end

  describe 'scoping' do
    before :each do
      user_with_group
    end

    it 'should return only active group memberships' do
      expect(@group.group_memberships).to include @group_membership
      @group_membership.destroy
      expect(@group.group_memberships).to_not include @group_membership
    end

    it 'should return only active users' do
      expect(@group.users).to include @user
      @user.destroy
      expect(@group.users).to_not include @user
    end

    it 'should return active groups in an active scope' do
      expect(Group.active).to include @group
      @group.destroy
      expect(Group.active).to_not include @group
    end
  end

  describe 'deleting users' do
    it 'should remove the user from the group' do
      @group = create :group
      @user = create :user
      @group.remove_user @user
      expect(@group.users).not_to include @user
    end
  end

  describe 'adding users' do
    it 'should add a user to a group' do
      @group = create :group
      @user = create :user
      @group.add_user @user
      expect(@group.users).to include @user
    end

    it 'should resurrect deleted group memberships' do
      group_with_user
      @group_membership.destroy
      expect(@group.users).to_not include @user
      gm = @group.add_user @user
      expect(@group_membership.reload).to eql gm
    end
  end
end
