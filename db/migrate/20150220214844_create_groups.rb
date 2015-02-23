class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :state
      t.text :settings


      t.timestamps null: false
    end
  end
end
