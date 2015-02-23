class RemoveRollFromGroupMembership < ActiveRecord::Migration
  def change
    remove_column :group_memberships, :roll, :string
  end
end
