class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :monetary_transactions do |t|
      t.references :user, index: true
      t.string :transaction_type
      t.decimal :amount, precision: 6, scale: 2
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :monetary_transactions, :users
  end
end
