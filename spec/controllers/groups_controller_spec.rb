 require 'rails_helper'

RSpec.describe GroupsController, :type => :controller do
  describe 'GET index' do
    before(:each) do
      logged_in_user
      @group = create :group
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
        @group = create :group
        post :create, format: :json, group: { name: 'a' }
        expect(response.status).to eql 400
      end
    end

    context 'html request' do
      it 'should create a group' do
        post :create, format: :html, group: { name: SecureRandom.uuid }
        expect(response.status).to eql 302
        expect(response).to redirect_to(group_path(assigns(:group)))
      end

      it 'should render #new upon failure' do
        post :create, format: :html, group: { name: 'a' }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT group' do
    before :each do
      logged_in_user
      @group = create :group
    end

    context 'json request' do
      it 'should update a group' do
        put :update, format: :json, id: @group.id, group: { name: SecureRandom.uuid }
        expect(response.status).to eql 200
      end

      it 'should show an error if validations fail' do
        @group1 = @group
        @group = create :group
        put :update, format: :json, id: @group1.id, group: { name: 'b' }
        expect(response.status).to eql 400
      end
    end

    context 'html request' do
      it 'should update a group' do
        put :update, format: :html, id: @group.id, group: { name: SecureRandom.uuid }
        expect(response).to redirect_to(group_path(assigns(:group)))
      end

      it 'should render #edit upon failure' do
        put :update, format: :html, id: @group.id, group: { name: 'a' }
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'DELETE group' do
    before :each do
      @group = create :group
      logged_in_user
    end

    context 'json request' do
      it 'should delete a group' do
        delete :destroy, format: :json, id: @group.id
        expect(response.status).to eql 204
      end
    end

    context 'html request' do
      it 'should delete a group' do
        delete :destroy, format: :html, id: @group.id
        expect(response).to redirect_to(groups_path)
      end
    end
  end

  describe 'GET users' do
    before(:each) do
      @group = create :group
      @group_membership = create :group_membership, group: @group
      logged_in_user
    end

    it 'should return users in a group' do
      get :users, group_id: @group.id, format: :json
      json = JSON.parse(response.body)
      expect(json['results'].map { |a| a['user_id'] }).to eql @group.users.pluck(:id)
    end
  end

  describe 'GET show' do
    before :each do
      @group = create :group
      @group_membership = create :group_membership, group: @group
      logged_in_user
    end

    it 'should return a group' do
      get :show, id: @group.id, format: :json
      expect(response.status).to eql 200
      json = JSON.parse response.body
      expect(json['id']).to eql @group.id
    end
  end
end

