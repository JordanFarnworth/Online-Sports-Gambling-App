require 'rails_helper'

RSpec.describe RoleMembershipsController, type: :controller do
  describe 'POST create' do
    before :each do
      logged_in_user permissions: :all
    end

    it 'should create a role membership' do
      u = create :user
      post :create, format: :json, role_id: @role.id, role_membership: { user_id: u.id }
      expect(response.status).to eql 200
      json = JSON.parse response.body
      expect(@role.role_memberships.pluck(:id)).to include(json['id'])
      expect(json['user']['id']).to eql u.id
    end
  end

  describe 'DELETE destroy' do
    before :each do
      logged_in_user permissions: :all
    end

    it 'should delete a role membership' do
      delete :destroy, format: :json, role_id: @role.id, id: @role_membership.id
      expect(response.status).to eql 204
      @role_membership.reload
      expect(@role_membership.state).to eql 'deleted'
    end
  end
end
