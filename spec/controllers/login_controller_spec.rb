require 'rails_helper'

RSpec.describe LoginController, :type => :controller do
  describe 'GET index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'POST index' do
    before :all do
      @user = create :user, password: 'abcd'
    end

    describe 'successful login' do
      let :params do
        { username: @user.username, password: 'abcd' }
      end

      it 'should assign a new login session as a cookie' do
        post :verify, params
        expect(response.cookies['sports_b_key']).to_not be_nil
      end

      it 'the key in the cookie should match the hashed key in the database' do
        post :verify, params
        jar = @request.cookie_jar
        ls = LoginSession.find_by(key: SecurityHelper.sha_hash(response.cookies['sports_b_key']))
        expect(SecurityHelper.sha_hash(response.cookies['sports_b_key'])).to eql ls.key
      end

      it 'should belong to the user' do
        post :verify, params
        ls = LoginSession.find_by(key: SecurityHelper.sha_hash(response.cookies['sports_b_key']))
        expect(@user).to eql ls.user
      end

      it 'should redirect to root upon completion' do
        post :verify, params
        expect(response).to redirect_to(:root)
      end
    end

    describe 'unsuccessful login' do
      let(:params) do
        { username: @user.username, password: '1234' }
      end

      it 'should display a flash error message' do
        post :verify, params
        expect(flash[:error]).to be_present
      end

      it 'should render the login#index view' do
        post :verify, params
        expect(response).to render_template('index')
      end
    end
  end

  describe 'DELETE index' do
    before(:all) do
      @user = create :user, password: 'abcd'
    end

    let(:params) do
      { username: @user.username, password: 'abcd' }
    end

    it 'should expire the login session' do
      post(:verify, params)
      ls = LoginSession.find_by_key SecurityHelper.sha_hash(response.cookies['sports_b_key'])
      delete :logout
      ls.reload
      expect(ls.expired?).to be_truthy
    end

    it 'should delete the session cookie' do
      post(:verify, params)
      delete :logout
      expect(response.cookies['sports_b_key']).to be_nil
    end

    it 'should display a flash notice message' do
      post(:verify, params)
      delete :logout
      expect(flash[:notice]).to be_present
    end

    it 'should redirect to root' do
      post(:verify, params)
      delete :logout
      expect(response).to redirect_to(:root)
    end
  end
end