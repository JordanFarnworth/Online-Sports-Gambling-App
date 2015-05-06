class CreateEventDays < ActiveRecord::Migration
  def change
    create_table :event_days do |t|
      t.string :event_day_tag
      t.string :sport

      t.timestamps null: false
    end
  end
end
