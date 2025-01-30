# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :group, default: false, null: false
      t.references :owner, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
