require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    let(:event) { build :event }

    it 'should receive a default state' do
      event.save
      expect(event.state).to eql 'not_started'
    end

    it 'should require a valid state' do
      event.state = 'asdf'
      expect(event.save).to be_falsey
    end

    it 'should require a start time' do
      event.event_starts_at = nil
      expect(event.save).to be_falsey
      event.event_starts_at = Time.now
      expect(event.save).to be_truthy
    end

    it 'should require a sport' do
      event.sport = nil
      expect(event.save).to be_falsey
    end
  end

  describe 'scoping' do
    let(:event) { create :event }

    it 'returns events that have not started' do
      expect(Event.not_started).to include event
    end

    it 'returns events that are in progress' do
      event.start
      expect(Event.not_started).to_not include event
      expect(Event.in_progress).to include event
    end

    it 'returns events that are completed' do
      event.complete
      expect(Event.in_progress).to_not include event
      expect(Event.completed).to include event
    end

    it 'returns events that occur on a given day' do
      event.update event_starts_at: 1.day.ago
      expect(Event.on_date(Time.now)).to_not include event
      event.update event_starts_at: Time.now
      expect(Event.on_date(Time.now)).to include event
      expect(Event.on_date(1.day.from_now)).to_not include event
    end
  end

  describe 'state changing' do
    let(:event) { create :event }

    it 'should mark an event as in progress' do
      event.start
      expect(event.state).to eql 'in_progress'
    end

    it 'should mark an event as complete' do
      event.complete
      expect(event.state).to eql 'completed'
    end
  end

  describe 'lobbies' do
    let(:event) { create :event }

    it 'should have lobbies' do
      expect(event).to respond_to :lobbies
    end

    it 'should mark lobbies as deleted when the event is deleted' do
      lobby = create :lobby, event: event
      expect(lobby.state).to_not eql 'deleted'

      event.destroy
      expect(lobby.reload.state).to eql 'deleted'
    end
  end

  describe 'event participants' do
    let(:event) { create :event }

    it 'has many event participants' do
      expect(event).to respond_to :event_participants
    end

    it 'returns a winner only when marked as complete' do
      ep = create :event_participant, event: event
      expect(event.winner).to be_nil
      event.complete
      expect(event.winner).to eql ep
    end
  end
end
