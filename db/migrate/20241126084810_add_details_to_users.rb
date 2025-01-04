# frozen_string_literal: true

class AddDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.text :description
      t.string :place
      t.string :website
      t.string :user_name
    end
    add_index :users, :user_name, unique: true
  end
end
