require "bitly"
include ActionView::Helpers::DateHelper

class Race < ActiveRecord::Base
  
  has_many :twitter_tweets
  default_scope :order => "created_at DESC"
  
  validates_presence_of :term1
  validates_presence_of :term2
  validates_numericality_of :last_tweet1, :allow_nil => false #, :only_integer => true
  validates_numericality_of :last_tweet2, :allow_nil => false #, :only_integer => true
  validates_numericality_of :race_to, :only_integer =>  true
  
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
      won_at = self.twitter_tweets.find_by_term(winner, :order => "twitter_id DESC").twitter_id
      extras = self.twitter_tweets.twitter_id_greater_than(won_at)
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
      
      deletable1s = self.twitter_tweets.find_all_by_term(winner, :order => "twitter_id DESC", :limit => num_extra_terms)
      deletable1s.each do |t|
        t.destroy
      end
      self.save!
    end
  end
  
  def initialize_last_tweets
    httpauth = Twitter::HTTPAuth.new(TWITTER_EMAIL, TWITTER_PASSWORD)
    client = Twitter::Base.new(httpauth)
    term1_tweets = Twitter::Search.new(self.term1).per_page(1).fetch().results
    term2_tweets = Twitter::Search.new(self.term2).per_page(1).fetch().results
    if term1_tweets.size > 0
      self.last_tweet1 = term1_tweets.first.id.to_s
    else
      self.last_tweet1 = 0
    end
    if term2_tweets.size > 0
      self.last_tweet2 = term2_tweets.first.id.to_s
    else
      self.last_tweet2 = 0
    end
    self.save!
  end
  # ToDo: Only update if it's been at least delay seconds.
  def update_status
    begin
      puts "Updating Status..."
      httpauth = Twitter::HTTPAuth.new(TWITTER_EMAIL, TWITTER_PASSWORD)
      client = Twitter::Base.new(httpauth)
      max_results1 = self.race_to - count1
      max_results2 = self.race_to - count2
      puts "Max Results 1: " + max_results1.to_s
      puts "Max Results 2: " + max_results2.to_s
    
      # Store the tweets\
      puts "Term 1: " + self.term1
      puts "Last Tweet 1: " + self.last_tweet1.to_s
      search1 = Twitter::Search.new(self.term1).since(self.last_tweet1).per_page(max_results1).page(1).fetch().results
      if !search1.nil?
        search1.each do |t|
          puts "  Result: " + t.inspect
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 1, :tweeted_at => t.created_at)
        end
      end
      puts "Term 2: " + self.term2
      puts "Last Tweet 2: " + self.last_tweet2.to_s
      search2 = Twitter::Search.new(self.term2).since(self.last_tweet2).per_page(max_results2).page(1).fetch().results
      if !search2.nil?
        search2.each do |t|
          puts "  Result: " + t.inspect
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 2, :tweeted_at => t.created_at)
        end
      end
      self.save!
      lta1 = self.twitter_tweets.term_equals(1).descend_by_twitter_id.first
      lta2 = self.twitter_tweets.term_equals(2).descend_by_twitter_id.first
      self.last_tweet1 = lta1.twitter_id if !lta1.nil?
      self.last_tweet2 = lta2.twitter_id if !lta2.nil?
      self.save!
    rescue Twitter::TwitterError => e
      self.save!
    end
    cleanup if complete?
    post_to_twitter if complete?
  end
end
