class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.text :permissions
      t.string :state
      t.string :protection_type

      t.timestamps null: false
    end
  end
end
