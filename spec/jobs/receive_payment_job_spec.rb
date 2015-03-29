require 'rails_helper'

RSpec.describe ReceivePaymentJob, type: :job do
  before :each do
    @payment = create :payment
    @params = { 'payment_method_nonce' => 'asdf' }
    allow(Braintree::Customer).to receive(:find).and_return(true)
    allow(Braintree::Customer).to receive(:create).and_raise(RuntimeError)
    allow(Braintree::Transaction).to receive(:sale).and_return(ExampleTransactionResponse.new(1000))
  end

  it 'should attempt to create a new braintree customer if one does not exist' do
    allow(Braintree::Customer).to receive(:find).and_raise(Braintree::NotFoundError)
    expect do
      ReceivePaymentJob.perform_now @payment, @params
    end.to raise_error RuntimeError
  end

  it 'should not attempt to create a new customer if one does exist' do
    expect do
      ReceivePaymentJob.perform_now @payment, @params
    end.to_not raise_error
  end

  it 'should record a braintree transaction id' do
    ReceivePaymentJob.perform_now @payment, @params
    expect(@payment.reload.braintree_transaction_id).to_not be_nil
  end

  it 'should mark a payment as processed' do
    ReceivePaymentJob.perform_now @payment, @params
    expect(@payment.reload.state).to eql 'processed'
  end

  it 'should mark a payment as failed' do
    allow(Braintree::Transaction).to receive(:sale).and_return(ExampleTransactionResponse.new(2000))
    ReceivePaymentJob.perform_now @payment, @params
    expect(@payment.reload.state).to eql 'failed'
  end

  it 'should fail a job if the gateway returns a failure' do
    allow(Braintree::Transaction).to receive(:sale).and_return(ExampleTransactionResponse.new(3000))
    expect do
      ReceivePaymentJob.perform_now @payment, @params
    end.to raise_error RuntimeError
  end
end

# Used to simulate a response that braintree would return
class ExampleTransactionResponse
  attr_accessor :transaction

  def initialize(code)
    self.transaction = TransactionParams.new(code)
  end

  class TransactionParams
    attr_accessor :id
    attr_accessor :processor_response_code

    def initialize(code)
      self.id = SecureRandom.hex
      self.processor_response_code = code
    end
  end
end