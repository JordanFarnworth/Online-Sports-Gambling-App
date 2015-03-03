require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe 'GET index' do
    before(:all) do
      User.update_all state: :deleted
      @user1 = user
      @user2 = user({ username: SecureRandom.uuid + 'blahblah' })
    end

    before :each do
      logged_in_user
    end

    context 'json request' do
      it 'should return users in json format' do
        get :index, format: :json
        expect(response.status).to eql 200
        expect {
          JSON.parse(response.body)
        }.to_not raise_error
        json = JSON.parse(response.body)
        expect(json['results'].map { |a| a['id'] }).to include(@user1.id, @user2.id)
      end

      it 'should return users based on a search parameter' do
        get :index, format: :json, search_term: 'blahblah'
        json = JSON.parse(response.body)
        expect(json['results'].map { |a| a['id'] }).to include(@user2.id)
      end
    end

    context 'html request' do
      it 'should render #index' do
        get :index, format: :html
        expect(response).to render_template('index')
      end
    end
  end

  describe 'DELETE destroy' do
    before :each do
      logged_in_user permissions: :all
    end

    context 'json request' do
      it 'should delete a user' do
        delete :destroy, format: :json, id: @user.id
        expect(response.status).to eql 204
      end
    end

    context 'html request' do
      it 'should delete a user' do
        delete :destroy, format: :html, id: @user.id
        expect(response).to redirect_to(users_path)
      end
    end
  end

  describe 'POST create' do
    before :each do
      logged_in_user permissions: :all
    end

    context 'html request' do
      it 'should create a user' do
        u = SecureRandom.uuid
        post :create, format: :html, user: { username: u, display_name: u, email: u + '@test.com', password: u, password_confirmation: u }
        expect(response).to redirect_to(user_path(assigns(:user)))
      end

      it 'should render #new upon failure' do
        u = SecureRandom.uuid
        post :create, format: :html, user: { username: u, display_name: u, email: u + '@test.com', password: u, password_confirmation: u + 'asdf' }
        expect(response).to render_template('new')
      end
    end
  end
end