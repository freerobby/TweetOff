class ConvertLastTweetsToBigints < ActiveRecord::Migration
  def self.up
    add_column :races, :last_tweet1_new, :bigint, :default => 0
    add_column :races, :last_tweet2_new, :bigint, :default => 0
    Race.find(:all).each do |race|
      race.last_tweet1_new = race.last_tweet1.to_i
      race.last_tweet2_new = race.last_tweet2.to_i
      race.save!
    end
    remove_column :races, :last_tweet1
    remove_column :races, :last_tweet2
    rename_column :races, :last_tweet1_new, :last_tweet1
    rename_column :races, :last_tweet2_new, :last_tweet2
  end

  def self.down
    add_column :races, :last_tweet1_new, :string
    add_column :races, :last_tweet2_new, :string
    Race.find(:all).each do |race|
      race.last_tweet1_new = race.last_tweet1.to_s
      race.last_tweet2_new = race.last_tweet2.to_s
      race.save!
    end
    remove_column :races, :last_tweet1
    remove_column :races, :last_tweet2
    rename_column :races, :last_tweet1_new, :last_tweet1
    rename_column :races, :last_tweet2_new, :last_tweet2
  end
end