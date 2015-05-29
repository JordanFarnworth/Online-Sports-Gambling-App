class CreateLobbies < ActiveRecord::Migration
  def change
    create_table :lobbies do |t|
      t.references :group, index: true
      t.datetime :betting_begins_at
      t.datetime :betting_ends_at
      t.text :settings
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :lobbies, :groups
  end
end
