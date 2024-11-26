class AddDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :description, :text
    add_column :users, :place, :string
    add_column :users, :website, :string
    add_column :users, :user_name, :string
    add_index :users, :user_name, unique: true
  end
end
