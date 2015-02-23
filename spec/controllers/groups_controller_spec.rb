require 'rails_helper'

RSpec.describe GroupsController, :type => :controller do
  describe 'GET index' do
    before(:each) do
      logged_in_user
      group
    end

    context 'json request' do
      it 'should return groups in json format' do
        get :index, format: :json
        expect(response.status).to eql 200
        expect {
          JSON.parse(response.body)
        }.to_not raise_error
        json = JSON.parse(response.body)
        expect(json.empty?).to be_falsey
      end
    end
  end

  describe 'POST index' do
    before :each do
      logged_in_user
    end

    context 'json request' do
      it 'should create a group' do
        post :create, format: :json, group: { name: SecureRandom.uuid }
        expect(response.status).to eql 200
      end

      it 'should show an error if validations fail' do
        group
        post :create, format: :json, group: { name: 'a' }
        expect(response.status).to eql 400
      end
    end
  end

  describe 'PUT group' do
    before :each do
      logged_in_user
      group
    end

    context 'json request' do
      it 'should update a group' do
        put :update, format: :json, id: @group.id, group: { name: SecureRandom.uuid }
        expect(response.status).to eql 200
      end

      it 'should show an error if validations fail' do
        @group1 = @group
        group
        put :update, format: :json, id: @group1.id, group: { name: 'b' }
        expect(response.status).to eql 400
      end
    end
  end

  describe 'DELETE group' do
    before :each do
      group
      logged_in_user
    end

    context 'json request' do
      it 'should delete a group' do
        delete :destroy, format: :json, id: @group.id
        expect(response.status).to eql 204
      end
    end
  end

  describe 'GET users' do
    before(:each) do
      group_with_user
      logged_in_user
    end

    it 'should return users in a group' do
      get :users, group_id: @group.id, format: :json
      json = JSON.parse(response.body)
      expect(json['results'].map { |a| a['id'] }).to eql @group.users.pluck(:id)
    end
  end
end

