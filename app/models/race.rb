include TwitterSearch

class Race < ActiveRecord::Base
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
    client = TwitterSearch::Client.new('TweetOff!')
    
    @tweets1 = Array.new
    @tweets2 = Array.new
    firstTime = true
    while self.count1 < self.race_to && self.count2 < self.race_to do
      begin
        sleep delay if !firstTime
        firstTime = false
        
        max_results1 = self.race_to - self.count1
        max_results2 = self.race_to - self.count2
        query1 = {:q => self.term1, :since_id => self.last_tweet1, :rpp => max_results1, :page => 1}
        query2 = {:q => self.term2, :since_id => self.last_tweet2, :rpp => max_results2, :page => 1}

        @tweets1 |= client.query(query1)
        @tweets2 |= client.query(query2)
        self.count1 += @tweets1.size
        self.count2 += @tweets2.size
        self.last_tweet1 = @tweets1.last.id.to_s if !@tweets1.last.nil?
        self.last_tweet2 = @tweets2.last.id.to_s if !@tweets2.last.nil?
        self.save
      rescue TwitterSearch::SearchServerError => e
        delay *= 1.5
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
end
