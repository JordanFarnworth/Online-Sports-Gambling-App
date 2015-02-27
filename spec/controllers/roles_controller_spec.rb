require 'rails_helper'

RSpec.describe RolesController, :type => :controller do
  describe 'GET index' do
    before(:each) do
      logged_in_user permissions: :all
      role
    end

    context 'json request' do
      it 'should return roles in json format' do
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
      logged_in_user permissions: :all
    end

    context 'json request' do
      it 'should create a role' do
        post :create, format: :json, role: { name: SecureRandom.uuid }
        expect(response.status).to eql 200
      end

      it 'should show an error if validations fail' do
        group
        post :create, format: :json, role: { name: @role.name }
        expect(response.status).to eql 400
      end
    end

    context 'html request' do
      it 'should create a role' do
        post :create, format: :html, role: { name: SecureRandom.uuid }
        expect(response).to redirect_to(role_path(assigns(:role)))
      end

      it 'should render #new on failure' do
        post :create, format: :html, role: { name: nil }
        expect(response).to render_template 'new'
      end
    end
  end

  describe 'PUT role' do
    before :each do
      logged_in_user permissions: :all
      role
    end

    context 'json request' do
      it 'should update a role' do
        put :update, format: :json, id: @role.id, role: { name: SecureRandom.uuid }
        expect(response.status).to eql 200
      end

      it 'should show an error if validations fail' do
        @role1 = @role
        role
        put :update, format: :json, id: @role1.id, role: { name: @role.name }
        expect(response.status).to eql 400
      end
    end

    context 'html request' do
      it 'should create a role' do
        put :update, format: :html, id: @role.id, role: { name: SecureRandom.uuid }
        expect(response).to redirect_to(role_path(assigns(:role)))
      end

      it 'should render #new on failure' do
        put :update, format: :html, id: @role.id, role: { name: nil }
        expect(response).to render_template 'edit'
      end
    end

    it 'should update permissions' do
      expect(@role.permissions[:assign_roles]).to be_falsey
      put :update, format: :json, id: @role.id, role: { name: @role.name }, permissions: { assign_roles: true }
      @role.reload
      expect(@role.permissions[:assign_roles]).to be_truthy
    end
  end

  describe 'DELETE role' do
    before :each do
      logged_in_user permissions: :all
      role
    end

    context 'json request' do
      it 'should delete a role' do
        delete :destroy, format: :json, id: @role.id
        expect(response.status).to eql 204
      end
    end

    context 'html request' do
      it 'should redirect to #index upon deletion' do
        delete :destroy, format: :html, id: @role.id
        expect(response).to redirect_to roles_path
      end
    end
  end

  describe 'GET users' do
    before(:each) do
      logged_in_user permissions: :all
      role_with_user
    end

    context 'json request' do
      it 'should return users in a role' do
        get :users, role_id: @role.id, format: :json
        json = JSON.parse(response.body)
        expect(json['results'].map { |a| a['id'] }).to eql @role.users.map(&:id)
      end
    end
  end

  # Meant to test authorization errors in ApplicationController
  describe 'authorization' do
    describe 'access denied' do
      before :each do
        logged_in_user
        role_with_user
      end

      it 'should redirect to root when receiving access denied with html' do
        get :index, format: :html
        expect(response).to redirect_to(root_path)
      end

      it 'should have a 401 status when receiving access denied with json' do
        get :index, format: :json
        expect(response.status).to eql 401
      end
    end

    it 'should recognize an API key' do
      user_with_role permissions: :all
      api_key

      request.headers['Authorization'] = "Bearer #{@key}"
      get :index, format: :json
      expect(response.status).to eql 200
    end
  end
end