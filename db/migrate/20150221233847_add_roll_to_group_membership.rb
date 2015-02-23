class AddRollToGroupMembership < ActiveRecord::Migration
  def change
    add_column :group_memberships, :roll, :string
  end
end
