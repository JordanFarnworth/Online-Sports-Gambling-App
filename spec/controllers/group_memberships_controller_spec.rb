require 'rails_helper'

RSpec.describe GroupMembershipsController, type: :controller do
  describe 'POST create' do
    before :each do
      logged_in_user permissions: :all
      @group = create :group
    end

    context 'json request' do
      it 'should create a group membership' do
        post :create, format: :json, group_membership: { user_id: @user.id, group_id: @group.id }
        expect(response.status).to eql 200
        expect(@group.users).to include @user
      end

      it 'should render an error message upon failure' do
        post :create, format: :json, group_membership: { user_id: @user.id, group_id: nil }
        expect(response.status).to eql 400
      end
    end
  end

  describe 'PUT update' do
    before :each do
      group_with_user
      logged_in_user
    end

    it 'should return no status on update' do
      put :update, format: :json, id: @group_membership.id, group_membership: { role: :moderator }
      expect(response.status).to eql 200
    end
  end

  describe 'DELETE destroy' do
    before :each do
      group_with_user
      logged_in_user
    end

    it 'should return no status on update' do
      delete :destroy, format: :json, id: @group_membership.id
      expect(response.status).to eql 200
    end
  end
end
