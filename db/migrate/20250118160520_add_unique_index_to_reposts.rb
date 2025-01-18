# frozen_string_literal: true

class AddUniqueIndexToReposts < ActiveRecord::Migration[7.0]
  def change
    add_index :reposts, %i[user_id post_id], unique: true, if_not_exists: true
  end
end
