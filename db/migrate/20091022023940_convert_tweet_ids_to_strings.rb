class ConvertTweetIdsToStrings < ActiveRecord::Migration
  def self.up
    change_column :races, :last_tweet1, :string, :allow_nil => true, :default => "0"
    change_column :races, :last_tweet2, :string, :allow_nil => true, :default => "0"
  end

  def self.down
    change_column :races, :last_tweet1, :integer, :allow_nil => true, :default => 0
    change_column :races, :last_tweet2, :integer, :allow_nil => true, :default => 0
  end
end
