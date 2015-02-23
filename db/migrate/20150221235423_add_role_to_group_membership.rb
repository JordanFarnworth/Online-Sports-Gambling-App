class AddRoleToGroupMembership < ActiveRecord::Migration
  def change
    add_column :group_memberships, :role, :string
  end
end
