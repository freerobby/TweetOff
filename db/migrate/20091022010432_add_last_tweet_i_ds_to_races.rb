class AddLastTweetIDsToRaces < ActiveRecord::Migration
  def self.up
    add_column :races, :last_tweet1, :integer, :default => 0, :allow_nil => false
    add_column :races, :last_tweet2, :integer, :default => 0, :allow_nil => false
  end

  def self.down
    remove_column :races, :last_tweet2
    remove_column :races, :last_tweet1
  end
end
