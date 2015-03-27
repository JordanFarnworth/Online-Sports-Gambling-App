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

  describe 'scoping' do
    before :each do
      payment
    end

    it 'should return payments in an initiated scope' do
      expect(Payment.initiated).to include @payment
      expect(Payment.processed).to_not include @payment
      expect(Payment.failed).to_not include @payment
    end

    it 'should return payments in a processed scope' do
      @payment.mark_as_processed!
      expect(Payment.initiated).to_not include @payment
      expect(Payment.processed).to include @payment
      expect(Payment.failed).to_not include @payment
    end

    it 'should return payments in a failed scope' do
      @payment.mark_as_failed!
      expect(Payment.initiated).to_not include @payment
      expect(Payment.processed).to_not include @payment
      expect(Payment.failed).to include @payment
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

    it 'should mark a payment as processed' do
      @payment.mark_as_processed!
      expect(@payment.reload.state).to eql 'processed'
    end

    it 'should mark a payment as failed' do
      @payment.mark_as_failed!
      expect(@payment.reload.state).to eql 'failed'
    end
  end

  it 'should mark a payment as failed if it has yet to be processed in 2 days' do
    payment
    expect(@payment.state).to eql 'initiated'
    Timecop.freeze(3.days.from_now) do
      expect(@payment.reload.state).to eql 'failed'
    end
    # Verify the failed state was saved to the table
    expect(@payment.reload.state).to eql 'failed'
  end
end
