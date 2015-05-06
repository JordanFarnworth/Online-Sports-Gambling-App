class AddBetAmountToLobby < ActiveRecord::Migration
  def change
    add_column :lobbies, :bet_amount, :decimal
  end
end
