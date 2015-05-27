class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.references :lobby, index: true
      t.references :event_participant, index: true
      t.references :user, index: true
      t.references :monetary_transaction, index: true
      t.decimal :bet_amount
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :bets, :lobbies
    add_foreign_key :bets, :event_participants
    add_foreign_key :bets, :users
    add_foreign_key :bets, :monetary_transactions
  end
end
