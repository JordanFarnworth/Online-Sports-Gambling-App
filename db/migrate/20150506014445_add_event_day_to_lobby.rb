class AddEventDayToLobby < ActiveRecord::Migration
  def change
    add_reference :lobbies, :event_day, index: true
    add_foreign_key :lobbies, :event_days
  end
end
