class AddEventToLobby < ActiveRecord::Migration
  def change
    add_reference :lobbies, :event, index: true
    add_foreign_key :lobbies, :events
  end
end
