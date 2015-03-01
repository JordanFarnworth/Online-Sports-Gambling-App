require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    before :each do
      payment
    end

    it 'should have a user' do
      @payment.user = nil
      expect(@payment.save).to be_falsey
    end

    it 'should have a valid state' do
      @payment.state = 'asdf'
      expect(@payment.save).to be_falsey
    end

    it 'should require an amount greater than 0' do
      @payment.amount = 0
      expect(@payment.save).to be_falsey
    end

    it 'should require an amount to be less than 10000' do
      @payment.amount = 10001
      expect(@payment.save).to be_falsey
    end

    it 'should require a valid gateway' do
      @payment.gateway = 'asdf'
      expect(@payment.save).to be_falsey
    end

    it 'should receive a default state' do
      expect(@payment.state).to eql 'initiated'
    end
  end

  describe 'creation' do
    it 'should not allow gateway_url to be called if not saved' do
      p = Payment.new
      expect { p.gateway_url }.to raise_error
    end

    it 'should allow gateway_url to be called if saved' do
      payment
      expect { @payment.gateway_url }.to_not raise_error
    end

    it 'should make a reference to the uuid of the payment' do
      payment
      expect(@payment.gateway_url.match(@payment.uuid)).to_not be_nil
    end
  end

  describe 'processing' do
    before :each do
      payment
    end

    it 'should create a transaction when marked as processed' do
      @payment.update state: 'processed'
      expect(@payment.monetary_transaction).to_not be_nil
    end
  end
end
