class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :body
      t.string :state
      t.references :sender, index: true

      t.timestamps null: false
    end

    add_foreign_key :messages, :users, column: :sender_id
  end
end
