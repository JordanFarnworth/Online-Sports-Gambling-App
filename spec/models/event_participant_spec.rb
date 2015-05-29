require 'rails_helper'

RSpec.describe EventParticipant, type: :model do
  describe 'validations' do
    let(:event_participant) { build :event_participant }

    it 'should receive a default outcome' do
      event_participant.save
      expect(event_participant.outcome).to eql 0.0
    end

    it 'should require an event' do
      event_participant.event = nil
      expect(event_participant.save).to be_falsey
    end

    it 'should require a name' do
      event_participant.name = nil
      expect(event_participant.save).to be_falsey
    end

    it 'should inherit a code from name' do
      event_participant.save
      expect(event_participant.name).to eql event_participant.code
    end
  end

  describe 'associations' do
    let(:event_participant) { create :event_participant }

    it 'has many bets' do
      expect(event_participant).to respond_to :bets
    end
  end

  describe 'scoping' do
    let(:event_participant) { create :event_participant }

    it 'should order event participants' do
      ep1 = create :event_participant
      ep2 = create :event_participant, outcome: 1.0
      expect(EventParticipant.ordered.pluck(:id)).to eql [ep2.id, ep1.id]
    end
  end
end
