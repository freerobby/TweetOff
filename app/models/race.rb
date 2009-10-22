include TwitterSearch

class Race < ActiveRecord::Base
  has_many :twitter_tweets
  
  validates_presence_of :term1
  validates_presence_of :term2
  validates_presence_of :last_tweet1
  validates_presence_of :last_tweet2
  validates_numericality_of :count1, :only_integer => true
  validates_numericality_of :count2, :only_integer => true
  validates_numericality_of :race_to, :only_integer => true
  
  after_create :initialize_last_tweets
  
  def go!
    delay = 3
    firstTime = true
    while self.count1 < self.race_to && self.count2 < self.race_to do
      begin
        sleep delay if !firstTime
        firstTime = false
        
        update_status
      end
    end
  end
  
  def winner
    if self.count1 > self.count2
      self.term1
    elsif self.count2 > self.count1
      self.term2
    else
      "It's a draw!"
    end
  end
  
  private
  def initialize_last_tweets
    client = TwitterSearch::Client.new('TweetOff!')
    last_tweet_with_term1 = client.query :q => term1, :rpp => 1
    last_tweet_with_term2 = client.query :q => term2, :rpp => 1
    if !last_tweet_with_term1.empty?
      self.last_tweet1 = last_tweet_with_term1.first.id.to_s
    end
    if !last_tweet_with_term2.empty?
      self.last_tweet2 = last_tweet_with_term2.first.id.to_s
    end
    self.save!
  end
  def update_status
    begin
      client = TwitterSearch::Client.new('TweetOff!')
      max_results1 = self.race_to - self.count1
      max_results2 = self.race_to - self.count2
      query1 = {:q => self.term1, :since_id => self.last_tweet1, :rpp => max_results1, :page => 1}
      query2 = {:q => self.term2, :since_id => self.last_tweet2, :rpp => max_results2, :page => 1}
      newTweets1 = client.query query1
      newTweets2 = client.query query2
    
      # Store the tweets
      newTweets1.each do |t|
        self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 1, :tweeted_at => t.created_at)
      end
      newTweets2.each do |t|
        self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 2, :tweeted_at => t.created_at)
      end
    
      self.count1 += newTweets1.size
      self.count2 += newTweets2.size
    
      self.last_tweet1 = newTweets1.last.id.to_s if !newTweets1.last.nil?
      self.last_tweet2 = newTweets2.last.id.to_s if !newTweets2.last.nil?
      self.save!
    rescue TwitterSearch::SearchServerError => e
      self.count1 = self.twitter_tweets.find_all_by_term(1).size
      self.count2 = self.twitter_tweets.find_all_by_term(2).size
      self.save!
    end
  end
end
