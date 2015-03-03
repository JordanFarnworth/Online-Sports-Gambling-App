require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    before :each do
      role
    end

    it 'should require a name' do
      @role.name = nil
      expect(@role.save).to be_falsey
    end

    it 'should load attributes from yml' do
      expect(@role.permissions.empty?).to be_falsey
    end

    it 'should not be able to be deleted if protected' do
      @role.protection_type = 'test'
      expect(@role.destroy).to be_falsey
    end

    it 'should receive a default state' do
      expect(@role.state).to eql 'active'
    end
  end
end
