require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  describe 'GET index' do
    before :each do
      logged_in_user
      payment
    end

    describe 'html request' do
      it 'should not query for payments' do
        get :index, format: :html
        expect(assigns(:payments)).to eql []
      end

      it 'should render the index template' do
        get :index, format: :html
        expect(response).to render_template 'index'
      end
    end

    describe 'json request' do
      it 'should return only payments belonging to the logged in user' do
        pay2 = create :payment, user: create(:user)
        get :index, format: :json
        payments = assigns(:payments)
        expect(payments).to include @payment
        expect(payments).to_not include pay2
      end

      it 'should order payments in descending order by created_at' do
        pay2 = create :payment, user: @user
        get :index, format: :json
        payments = assigns(:payments).to_a
        expect(payments).to eql [pay2, @payment]
      end

      it 'should properly handle an initiated scope' do
        get :index, format: :json, scope: 'initiated'
        expect(assigns(:payments)).to include @payment
        get :index, format: :json, scope: 'failed'
        expect(assigns(:payments)).to_not include @payment
        get :index, format: :json, scope: 'processed'
        expect(assigns(:payments)).to_not include @payment
      end

      it 'should properly handle a failed scope' do
        @payment.mark_as_failed!
        get :index, format: :json, scope: 'initiated'
        expect(assigns(:payments)).to_not include @payment
        get :index, format: :json, scope: 'failed'
        expect(assigns(:payments)).to include @payment
        get :index, format: :json, scope: 'processed'
        expect(assigns(:payments)).to_not include @payment
      end

      it 'should properly handle a processed scope' do
        @payment.mark_as_processed!
        get :index, format: :json, scope: 'initiated'
        expect(assigns(:payments)).to_not include @payment
        get :index, format: :json, scope: 'failed'
        expect(assigns(:payments)).to_not include @payment
        get :index, format: :json, scope: 'processed'
        expect(assigns(:payments)).to include @payment
      end

      it 'should optionally include transactions' do
        get :index, format: :json
        expect(parse_json(response.body)['results'].any? { |p| p['transaction'] }).to be_falsey

        get :index, format: :json, include: ['transaction']
        expect(parse_json(response.body)['results'].all? { |p| p.keys.include? 'transaction' }).to be_truthy
      end
    end
  end

  describe 'POST create' do
    before :each do
      logged_in_user
    end

    it 'should create a new receive payment job upon success' do
      post :create, payment: { amount: 5 }, payment_method_nonce: 'asdf'
      expect(Delayed::Job.last.handler).to match /ReceivePaymentJob/
    end

    it 'should redirect to payments#show upon success' do
      post :create, payment: { amount: 5 }, payment_method_nonce: 'asdf'
      expect(response).to redirect_to payment_path(assigns(:payment).uuid)
    end

    it 'should render new upon failure' do
      post :create, payment: { amount: -1 }
      expect(response).to render_template 'new'
    end
  end
end
