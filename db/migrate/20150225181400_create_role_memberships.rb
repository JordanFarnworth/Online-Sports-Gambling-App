class CreateRoleMemberships < ActiveRecord::Migration
  def change
    create_table :role_memberships do |t|
      t.references :user, index: true
      t.references :role, index: true
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :role_memberships, :users
    add_foreign_key :role_memberships, :roles
  end
end
