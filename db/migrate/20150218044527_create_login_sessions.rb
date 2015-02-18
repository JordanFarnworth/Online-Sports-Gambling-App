class CreateLoginSessions < ActiveRecord::Migration
  def change
    create_table :login_sessions do |t|
      t.references :user, index: true
      t.string :key
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_foreign_key :login_sessions, :users
  end
end
