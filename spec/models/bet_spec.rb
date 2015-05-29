require 'rails_helper'

RSpec.describe Bet, type: :model do
  let(:bet) { create :bet }

  describe 'validations' do
    it 'requires a lobby' do
      bet.lobby = nil
      expect(bet.save).to be_falsey
    end

    it 'requires an event_participant' do
      bet.event_participant = nil
      expect(bet.save).to be_falsey
    end

    it 'requires a user' do
      bet.user = nil
      expect(bet.save).to be_falsey
    end

    it 'requires a user and lobby be unique' do
      b2 = build :bet, lobby: bet.lobby
      expect(b2.save).to be_truthy
      b2 = build :bet, user: bet.user
      expect(b2.save).to be_truthy
      b2 = build :bet, user: bet.user, lobby: bet.lobby
      expect(b2.save).to be_falsey
    end

    it 'requires a user have available funds to place a bet' do
      bet = build :bet
      bet.user.update balance: 0
      expect(bet.save).to be_falsey
    end
  end

  it 'creates a monetary transaction' do
    expect(bet.monetary_transaction).to_not be_nil
  end

  describe 'deletion' do
    it 'is marked as cancelled' do
      bet.destroy
      expect(bet.state).to eql 'cancelled'
    end

    it 'deletes a linked monetary transaction' do
      bet.destroy
      expect(bet.monetary_transaction.state).to eql 'cancelled'
    end
  end
end
