class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :user, index: true
      t.string :purpose
      t.string :key
      t.string :key_hint
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_foreign_key :api_keys, :users
  end
end
