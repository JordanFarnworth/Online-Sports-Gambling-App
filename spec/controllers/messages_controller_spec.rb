require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  describe 'GET index' do
    before :each do
      @user = create :user
      message
      logged_in_user
    end

    it 'should only return messages which one is a participant of' do
      get :index, format: :json
      json = JSON.parse(response.body)['results']
      expect(json.map { |m| m['id'] }).to include(@message.id)
    end

    it 'should not return messages which one is not a participant of' do
      @user = nil
      logged_in_user
      get :index, format: :json
      json = JSON.parse(response.body)['results']
      expect(json.map { |m| m['id'] }).to_not include(@message.id)
    end

    it 'should return information about the sender' do
      get :index, format: :json, include: ['sender']
      json = JSON.parse(response.body)['results']
      expect(json.map { |m| m['sender']['id'] }).to include(@user.id)
    end
  end

  describe 'GET show' do
    before :each do
      message
      logged_in_user
    end

    it 'should allow a user to view a message if they are a participant' do
      get :show, format: :json, id: @message.id
      json = JSON.parse(response.body)
      expect(response.status).to eql 200
    end

    it 'should now allow a user to view a message if they are not a participant' do
      @user = nil
      logged_in_user
      get :show, format: :json, id: @message.id
      expect(response.status).to eql 404
    end

    it 'should return information about the sender' do
      get :show, format: :json, id: @message.id, include: ['sender']
      json = JSON.parse(response.body)
      expect(json['sender']['id']).to eql @user.id
    end
  end

  describe 'POST create' do
    before :each do
      logged_in_user
    end

    it 'should create messages' do
      u = create :user
      post :create, format: :json, message: { subject: 'asdf', body: 'asdf', message_participants_attributes: [ { user_id: u.id } ] }
      expect(response.status).to eql 200
    end

    it 'should return an error upon failure' do
      post :create, format: :json, message: { subject: 'asdf', body: 'asdf', message_participants_attributes: [ { user_id: @user.id } ] }
      expect(response.status).to eql 400
    end
  end

  describe 'DELETE destroy' do
    before :each do
      message
      logged_in_user
    end

    it 'should delete a message' do
      delete :destroy, format: :json, id: @message.id
      expect(response.status).to eql 204
    end
  end

  describe 'PUT update' do
    before :each do
      message
      logged_in_user
    end

    it 'should mark a message as read' do
      put :update, format: :json, id: @message.id, message: { state: 'read' }
      json = JSON.parse(response.body)
      expect(response.status).to eql 200
      expect(json['state']).to eql 'read'
    end

    it 'should return an error upon failure' do
      put :update, format: :json, id: @message.id, message: { state: 'not_a_real_state' }
      expect(response.status).to eql 400
    end
  end

  describe 'GET search_recipients' do
    before :each do
      logged_in_user
    end

    it 'should return users based on a search term' do
      get :search_recipients, format: :json, search_term: @user.display_name
      expect(response.status).to eql 200

      json = JSON.parse(response.body)
      expect(json.length).to eql 1
      expect(json.map { |j| j['id'] }).to include(@user.id)
      expect(json.map { |j| j['display_name'] }).to include(@user.display_name)
    end
  end
end
