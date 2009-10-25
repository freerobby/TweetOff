class ConvertTwitterIdToBigInt < ActiveRecord::Migration
  def self.up
    add_column :twitter_tweets, :twitter_id2, :bigint
    TwitterTweet.find(:all).each do |tt|
      tt.twitter_id2 = tt.twitter_id.to_i
      tt.save!
    end
    remove_column :twitter_tweets, :twitter_id
    rename_column :twitter_tweets, :twitter_id2, :twitter_id
  end

  def self.down
    add_column :twitter_tweets, :twitter_id2, :string
    TwitterTweet.find(:all).each do |tt|
      tt.twitter_id2 = tt.twitter_id.to_s
      tt.save!
    end
    remove_column :twitter_tweets, :twitter_id
    rename_column :twitter_tweets, :twitter_id2, :twitter_id
  end
end
