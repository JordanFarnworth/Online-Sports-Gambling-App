class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :sport
      t.datetime :event_starts_at
      t.string :state

      t.timestamps null: false
    end
  end
end
