class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :monetary_transaction, index: true
      t.references :user, index: true
      t.string :uuid
      t.string :gateway
      t.decimal :amount, precision: 6, scale: 2
      t.string :state
      t.text :parameters

      t.timestamps null: false
    end
    add_foreign_key :payments, :monetary_transactions
    add_foreign_key :payments, :users
  end
end
