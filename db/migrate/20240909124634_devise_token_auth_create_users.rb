# frozen_string_literal: true

class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :provider, null: false, default: 'email'
      t.string :uid, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean :allow_password_change, null: false, default: false
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.date :birthdate, null: false
      t.json :tokens
      t.timestamps
    end

    add_index :users, :name, unique: true
    add_index :users, :email, unique: true
    add_index :users, %i[uid provider], unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
  end
end
