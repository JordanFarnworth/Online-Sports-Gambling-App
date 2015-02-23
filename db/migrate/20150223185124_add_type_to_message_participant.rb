class AddTypeToMessageParticipant < ActiveRecord::Migration
  def change
    add_column :message_participants, :user_type, :string
  end
end
