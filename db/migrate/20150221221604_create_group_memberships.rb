class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.references :user, index: true
      t.references :group, index: true

      t.timestamps null: false
    end
    add_foreign_key :group_memberships, :users
    add_foreign_key :group_memberships, :groups
  end
end
