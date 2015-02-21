class AddStateToGroupMembership < ActiveRecord::Migration
  def change
    add_column :group_memberships, :state, :string
  end
end
