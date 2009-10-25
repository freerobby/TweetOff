require "bitly"
include TwitterSearch
include ActionView::Helpers::DateHelper

class Race < ActiveRecord::Base
  
  has_many :twitter_tweets
  default_scope :order => "created_at DESC"
  
  validates_presence_of :term1
  validates_presence_of :term2
  validates_presence_of :last_tweet1
  validates_presence_of :last_tweet2
  validates_numericality_of :count1, :only_integer => true
  validates_numericality_of :count2, :only_integer => true
  validates_numericality_of :race_to, :only_integer => true
  
  after_create :initialize_last_tweets
  
  named_scope :complete, :conditions => {:complete? => true}
  
  def go!
    update_status if count1 < self.race_to && count2 < self.race_to && (Time.now > (self.updated_at + TWITTER_REFRESH_INTERVAL))
  end
  
  def winner
    if count1 > count2
      1
    elsif count2 > count1
      2
    else
      0
    end
  end
  def loser
    if winner == 0
      0
    elsif winner == 1
      2
    else
      1
    end
  end
  def winning_term
    if winner == 1
      self.term1
    elsif winner == 2
      self.term2
    else
      "Nobody"
    end
  end
  
  def count1
    self.twitter_tweets.find_all_by_term(1).size
  end
  def count2
    self.twitter_tweets.find_all_by_term(2).size
  end
  
  def complete?
    count1 >= self.race_to || count2 >= self.race_to
  end
  
  def began_at
    self.created_at
  end
  def ended_at
    ts = self.twitter_tweets.all(:order => "tweeted_at DESC", :limit => 1).first
    if ts.nil?
      self.updated_at
    else
      ts.tweeted_at
    end
  end
  
  def duration
    ended_at - began_at
  end
  
  def link_to_show
    @bitly = ::Bitly.new(BITLY_USER, BITLY_APIKEY)
    @bitly.shorten(APP_BASE + "/races/" + self.id.to_s).short_url
  end
  
  private
  def generate_twitter_status
    if winner == 0
      "It's a draw! \"" + self.term1 + "\" and \"" + self.term2 + "\" both got " + count1.to_s + " mentions in " + (distance_of_time_in_words duration) + ". " + link_to_show
    elsif winner == 1
      "In a span of " + (distance_of_time_in_words duration) + ", " + "\"" + self.term1 + "\"" + " got " + self.count1.to_s + " mentions and bested " + "\"" + self.term2 + "\"" + ", which got " + self.count2.to_s + ". " + link_to_show
    else # winner == 2
      "In a span of " + (distance_of_time_in_words duration) + ", " + "\"" + self.term2 + "\"" + " got " + self.count2.to_s + " mentions and bested " + "\"" + self.term1 + "\"" + ", which got " + self.count1.to_s + ". " + link_to_show
    end
  end
  
  def post_to_twitter
    httpauth = Twitter::HTTPAuth.new(TWITTER_EMAIL, TWITTER_PASSWORD)
    client = Twitter::Base.new(httpauth)
    client.update(generate_twitter_status)
  end
  
  # If we find too many results in a single pull, clean up accordingly for accurate results.
  def cleanup
    remove_tweets_past_finish_line if count1 > race_to || count2 > race_to
    break_tie_by_tweet_ids if count1 > 0 && count2 > 0
    remove_extras
  end
  
  def break_tie_by_tweet_ids
    if count1 == count2
      last_term1 = self.twitter_tweets.find_by_term(1, :order => "twitter_id DESC")
      last_term2 = self.twitter_tweets.find_by_term(2, :order => "twitter_id DESC")
    
      if last_term1.twitter_id.to_i < last_term2.twitter_id.to_i
        last_term2.destroy
      elsif last_term2.twitter_id.to_i < last_term1.twitter_id.to_i
        last_term1.destroy
      end
      self.save!
    end
  end
  
  def remove_extras
    # Find out when the race was won, and remove any tweets from the loser that came after that.
    if winner > 0
      won_at = self.twitter_tweets.find_by_term(winner, :order => "tweeted_at DESC").twitter_id
      extras = self.twitter_tweets.term_equals(loser).twitter_id_greater_than(won_at).all(:order => "tweeted_at DESC")
      extras.each do |e|
        e.destroy
      end
      self.save!
    end
  end
  
  def remove_tweets_past_finish_line
    if winner > 0
      num_extra_terms = 0
      num_extra_terms = count1 - self.race_to if winner == 1
      num_extra_terms = count2 - self.race_to if winner == 2
      
      deletable1s = self.twitter_tweets.find_all_by_term(winner, :order => "tweeted_at DESC", :limit => num_extra_terms)
      deletable1s.each do |t|
        t.destroy
      end
      self.save!
    end
  end
  
  def initialize_last_tweets
    client = TwitterSearch::Client.new('TweetOff!')
    last_tweet_with_term1 = client.query :q => self.term1, :rpp => 1
    last_tweet_with_term2 = client.query :q => self.term2, :rpp => 1
    if !last_tweet_with_term1.empty?
      self.last_tweet1 = last_tweet_with_term1.first.id.to_s
    end
    if !last_tweet_with_term2.empty?
      self.last_tweet2 = last_tweet_with_term2.first.id.to_s
    end
    self.save!
  end
  # ToDo: Only update if it's been at least delay seconds.
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
        # This if should not be necessary, but it is. Figure out why.
        if self.twitter_tweets.find_by_term_and_twitter_id(1, t.id).nil?
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 1, :tweeted_at => t.created_at)
        end
      end
      newTweets2.each do |t|
        # This if should not be necessary, but it is. Figure out why.
        if self.twitter_tweets.find_by_term_and_twitter_id(2, t.id).nil?
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 2, :tweeted_at => t.created_at)
        end
      end
      
      lta1 = self.twitter_tweets.find_by_term(1, :order => "twitter_id DESC")
      lta2 = self.twitter_tweets.find_by_term(2, :order => "twitter_id DESC")
      self.last_tweet1 = lta1.twitter_id.to_s if !lta1.nil?
      self.last_tweet2 = lta2.twitter_id.to_s if !lta2.nil?
      self.save!
    rescue TwitterSearch::SearchServerError => e
      self.save!
    end
    cleanup if complete?
    post_to_twitter if complete?
  end
end
