require 'rails_helper'

RSpec.describe EventDay, type: :model do
  describe 'validations' do
    before :each do
      @event_day = build :event_day
    end

    it 'should require an event day to be unique' do
      @event_day.save!
      expect(EventDay.new(event_day_tag: @event_day.event_day_tag).save).to be_falsey
    end

    it 'should require an event day to have a valid tag' do
      @event_day.event_day_tag = 'sportsball_200000_000_00'
      expect(@event_day.save).to be_falsey
      @event_day.event_day_tag = 'sportsball_2000_05_01'
      expect(@event_day.save).to be_truthy
    end

    context 'with existing models' do
      before :each do
        @event_day.save
      end

      it 'should infer a sport' do
        expect(@event_day.sport).to eql @event_day.event_day_tag.match(EventDay::TAG_REGEX)[1]
      end

      it 'should parse a date' do
        expect(@event_day.date).to eql Time.now.beginning_of_day
      end

      it 'should infer a date tag' do
        tag = EventDay.infer_date_tag 'nfl', Time.now
        expect(tag).to eql "nfl_#{Time.now.strftime('%Y_%m_%d')}"
      end

      it 'should find an event day with a sport and date' do
        expect(EventDay.for_sport_and_date(@event_day.sport, Time.now)).to eql @event_day
      end
    end
  end
end
