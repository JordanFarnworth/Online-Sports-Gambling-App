require 'rails_helper'

RSpec.describe Ability, type: :model do
  describe 'non-logged in user' do
    before :each do
      @user = User.new
      ability
    end

    it 'should not be able to perform any action on users' do
      [:create, :update, :read, :destroy].each do |p|
        expect(@ability.can?(p, User.new)).to be_falsey
      end
    end

    it 'should not be able to manipulate messages' do
      [:read, :create, :search_recipients].each do |p|
        expect(@ability.can?(p, Message.new)).to be_falsey
      end
    end

    it 'should not be able to manipulate message participants' do
      [:read, :destroy, :update].each do |p|
        expect(@ability.can?(p, MessageParticipant.new)).to be_falsey
      end
    end

    it 'should not be able to manipulate groups' do
      [:create, :read, :update, :destroy].each do |p|
        expect(@ability.can?(p, Group.new)).to be_falsey
      end
    end

    it 'should not be able to manipulate roles' do
      [:create, :read, :update, :destroy].each do |p|
        expect(@ability.can?(p, Role.new)).to be_falsey
      end
    end
  end

  describe 'end user' do
    before :each do
      ability
    end

    it 'should be able to read a user' do
      expect(@ability.can?(:read, User.new)).to be_truthy
    end

    it 'should only be able to update self' do
      expect(@ability.can?(:update, User.new)).to be_falsey
      expect(@ability.can?(:update, @user)).to be_truthy
    end

    it 'should be able to manipulate a message participant, if self is linked' do
      [:read, :destroy, :update].each do |p|
        expect(@ability.can?(p, MessageParticipant.new)).to be_falsey
        expect(@ability.can?(p, MessageParticipant.new(user: @user))).to be_truthy
      end
    end

    it 'should be able to read and create messages' do
      # These permissions are largely overshadowed by those in MessageParticipant,
      # so fine-tuned handling is unnecessary here
      expect(@ability.can?(:read, Message.new)).to be_truthy
      expect(@ability.can?(:create, Message.new)).to be_truthy
    end

    it 'should be able to search recipients' do
      expect(@ability.can?(:search_recipients, Message)).to be_truthy
    end

    it 'should not be able to manipulate roles' do
      [:create, :read, :update, :destroy].each do |p|
        expect(@ability.can?(p, Role)).to be_falsey
      end
    end
  end

  describe 'role permissions' do
    context 'manage_roles' do
      before :each do
        user_with_role permissions: [:manage_roles]
        ability
      end

      it 'should be able to read roles' do
        expect(@ability.can?(:read, Role)).to be_truthy
      end

      it 'should be able to manage roles' do
        expect(@ability.can?(:manage, Role)).to be_truthy
      end

      it 'should not be able to manage protected roles' do
        role protection_type: 'administrator'
        expect(@ability.can?(:manage, @role)).to be_falsey
      end
    end

    context 'assign_roles' do
      before :each do
        user_with_role permissions: [:assign_roles]
        ability
      end

      it 'should be able to read roles' do
        expect(@ability.can?(:read, Role)).to be_truthy
      end

      it 'should not be able to manage roles' do
        expect(@ability.can?(:manage, Role)).to be_falsey
      end
    end
  end
end
