class CreateEventParticipants < ActiveRecord::Migration
  def change
    create_table :event_participants do |t|
      t.references :event, index: true
      t.string :name
      t.string :code
      t.decimal :outcome

      t.timestamps null: false
    end
    add_foreign_key :event_participants, :events
  end
end
