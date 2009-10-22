class AddTweetsTable < ActiveRecord::Migration
  def self.up
    create_table :twitter_tweets do |t|
      t.string :text
      t.string :twitter_id
      t.string :author
      t.integer :race_id
      t.integer :term
      t.timestamp :tweeted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_tweets
  end
end