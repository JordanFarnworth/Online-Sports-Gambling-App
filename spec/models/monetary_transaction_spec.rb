require 'rails_helper'

RSpec.describe MonetaryTransaction, type: :model do
  describe 'validations' do
    before :each do
      transaction
    end

    it 'should require a valid state' do
      @transaction.state = 'asdf'
      expect(@transaction.save).to be_falsey
    end

    it 'should require a valid transaction type' do
      @transaction.transaction_type = 'asdf'
      expect(@transaction.save).to be_falsey
      @transaction.transaction_type = 'bet'
      @transaction.amount = -1
      expect(@transaction.save).to be_truthy
    end

    it 'should require a user' do
      @transaction.user = nil
      expect(@transaction.save).to be_falsey
    end

    it 'should require an amount greater than 0' do
      @transaction.amount = 0
      expect(@transaction.save).to be_falsey
    end

    it 'should require an amount to be less than 10000' do
      @transaction.amount = 10001
      expect(@transaction.save).to be_falsey
    end

    it 'requires a negative amount for bets and withdrawls' do
      @transaction.transaction_type = 'bet'
      expect(@transaction.save).to be_falsey
      @transaction.amount = -@transaction.amount
      expect(@transaction.save).to be_truthy
    end
  end

  describe 'amount handling' do
    before :each do
      transaction
    end

    it 'should update a user\'s balance based on transactions' do
      expect(@user.balance).to eql @transaction.amount
      amts = 5.times.to_a.map { |a| (Kernel.rand * 50).round(2) }
      a = @transaction.amount
      amts.each do |amt|
        a += amt
        transaction amount: amt
      end
      expect(@user.balance).to eql a.round(2)
    end
  end

  it 'should mark a transaction as cancelled' do
    transaction
    @transaction.destroy
    expect(@transaction.state).to eql 'cancelled'
  end

  describe 'transaction linking' do
    before :each do
      transaction
    end

    it 'should link to a payment' do
      payment transaction: @transaction
      expect(@transaction.linked_transaction).to eql @payment
    end

    it 'links with a bet' do
      bet = create :bet
      expect(bet.monetary_transaction.linked_transaction).to eql bet
    end
  end
end
