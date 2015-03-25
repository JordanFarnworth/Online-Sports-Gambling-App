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
end
