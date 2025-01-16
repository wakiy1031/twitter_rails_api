class DropRetweetsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :retweets
  end

  def down
    create_table :retweets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.timestamps
      t.index [:user_id, :post_id], unique: true
    end
  end
end
