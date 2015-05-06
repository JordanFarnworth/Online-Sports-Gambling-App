require 'rails_helper'

RSpec.describe Lobby, type: :model do
  before :each do
    @lobby = create :lobby
  end

  describe 'validations' do
    it 'should require a valid state' do
      expect(@lobby.update(state: :asdf)).to be_falsey
    end

    it 'should receive a default state' do
      expect(@lobby.state).to eql 'active'
    end

    it 'should require valid dates' do
      @lobby.betting_begins_at = Time.now
      @lobby.betting_ends_at = nil
      expect(@lobby.save).to be_truthy
      @lobby.betting_ends_at = 1.week.ago
      expect(@lobby.save).to be_falsey
    end
  end

  describe 'associations' do
    it 'should belong to a group' do
      expect(@lobby).to respond_to :group
    end
  end

  describe 'scoping' do
    it 'should return active lobbies' do
      expect(Lobby.active).to include @lobby
      expect(Lobby.completed).to_not include @lobby
    end

    it 'should return completed lobbies' do
      @lobby.update state: :completed
      expect(Lobby.active).to_not include @lobby
      expect(Lobby.completed).to include @lobby
    end

    it 'should not return deleted lobbies in an active scope' do
      @lobby.destroy
      expect(Lobby.active).to_not include @lobby
    end

    it 'should not return deleted lobbies in a completed scope' do
      @lobby.destroy
      expect(Lobby.completed).to_not include @lobby
    end

    it 'should return a lobby in an allows betting scope' do
      expect(Lobby.allows_betting).to include @lobby
    end

    it 'should not return a lobby in an allows betting scope if betting is completed' do
      @lobby.update betting_ends_at: 1.day.ago
      expect(Lobby.allows_betting).to_not include @lobby
    end
  end

  it 'should mark a lobby as deleted' do
    @lobby.destroy
    expect(@lobby.reload.state).to eql 'deleted'
  end

  it 'should correctly determine whether a lobby is open for bets' do
    # default dates
    expect(@lobby.allow_bets?).to be_truthy

    # Lobby in the past
    @lobby.betting_ends_at = 1.day.ago
    expect(@lobby.allow_bets?).to be_falsey

    # Lobby in the future
    @lobby.betting_ends_at = 2.days.from_now
    @lobby.betting_begins_at = 1.day.from_now
    expect(@lobby.allow_bets?).to be_falsey

    # Lobby with no begins date, ends in future
    @lobby.betting_begins_at = nil
    expect(@lobby.allow_bets?).to be_truthy
  end
end
