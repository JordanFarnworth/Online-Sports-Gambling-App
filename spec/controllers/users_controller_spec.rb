require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe 'GET index' do
    before(:all) do
      User.destroy_all
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
        expect(json['results'].map { |a| a['id'] }).to eql [@user2.id]
      end
    end
  end
end