class CreatePageViews < ActiveRecord::Migration
  def change
    create_table :page_views do |t|
      t.references :user, index: true
      t.references :real_user, index: true
      t.string :path
      t.string :ip_address
      t.string :http_method
      t.text :user_agent
      t.text :parameters
      t.string :referrer
      t.string :request_format
      t.string :controller
      t.string :action

      t.timestamps null: false
    end
    add_foreign_key :page_views, :users, column: :user_id
    add_foreign_key :page_views, :users, column: :real_user_id
  end
end
