# frozen_string_literal: true

class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_users_table
    add_indexes
  end

  private

  def create_users_table
    create_table(:users) do |t|
      ## Required
      t.string :provider, null: false, default: 'email'
      t.string :uid, null: false, default: ''

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''

      ## User Info
      t.string :name
      t.string :nickname
      t.string :image
      t.string :email

      ## Tokens
      t.json :tokens

      t.timestamps
    end
  end

  def add_indexes
    add_index :users, :email, unique: true
    add_index :users, %i[uid provider], unique: true
  end
end
