class CreateMessageParticipants < ActiveRecord::Migration
  def change
    create_table :message_participants do |t|
      t.references :user, index: true
      t.references :message, index: true
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :message_participants, :users
    add_foreign_key :message_participants, :messages
  end
end
