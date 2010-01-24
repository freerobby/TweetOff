require "bitly"
include ActionView::Helpers::DateHelper

class Race < ActiveRecord::Base
  
  belongs_to :user
  has_many :twitter_tweets
  default_scope :order => "created_at DESC"
  
  validates_presence_of :term1
  validates_presence_of :term2
  validates_numericality_of :last_tweet1, :allow_nil => false #, :only_integer => true
  validates_numericality_of :last_tweet2, :allow_nil => false #, :only_integer => true
  validates_numericality_of :race_to, :only_integer =>  true
  
  after_create :initialize_last_tweets
  
  def began_at
    self.created_at
  end
  
  def is_complete?
    count1 >= self.race_to || count2 >= self.race_to
  end
  
  def link_to_show
    bitly = ::Bitly.new(BITLY_USER, BITLY_APIKEY)
    bitly.shorten(APP_BASE + "/races/" + self.id.to_s).short_url
  end
  
  def loser
    return 0 if winner == 0
    return 1 if winner == 2
    2 # if winner == 1
  end
  
  def winner
    return 0 if count1 == count2
    return 1 if count1 > count2
    2 # if count2 > count1
  end
  
  def winning_term
    return "Nobody" if winner == 0
    return self.term1 if winner == 1
    self.term2 # if winner == 2
  end
  
  def count1
    self.twitter_tweets.term_equals(1).size
  end
  
  def count2
    self.twitter_tweets.term_equals(2).size
  end
  
  def ended_at
    ts = self.twitter_tweets.all(:order => "tweeted_at DESC", :limit => 1).first
    ts.nil? ? self.updated_at : ts.tweeted_at
  end
    
  def twitter_timeout_passed?
    (Time.now > (self.updated_at + TWITTER_REFRESH_INTERVAL))
  end
  
  def go!
    update_status if !(complete?) && !(is_complete?) && twitter_timeout_passed?
  end
  
  private
  def generate_twitter_status
    at_reply = self.user.nil? ? "" : " @" + self.user.login
    if winner == 0
      "It's a draw! \"" + self.term1 + "\" and \"" + self.term2 + "\" both got " + count1.to_s + " mentions in " + (distance_of_time_in_words began_at, ended_at) + ". " + link_to_show + at_reply
    elsif winner == 1
      "In " + (distance_of_time_in_words began_at, ended_at) + ", " + "\"" + self.term1 + "\"" + " got " + self.count1.to_s + " mentions, beating " + "\"" + self.term2 + "\"" + ", which got " + self.count2.to_s + ". " + link_to_show + at_reply
    else # winner == 2
      "In " + (distance_of_time_in_words began_at, ended_at) + ", " + "\"" + self.term2 + "\"" + " got " + self.count2.to_s + " mentions, beating " + "\"" + self.term1 + "\"" + ", which got " + self.count1.to_s + ". " + link_to_show + at_reply
    end
  end
  
  def get_twitter_client(tweetoff_account = false)
    if self.user.nil? || tweetoff_account
      httpauth = Twitter::HTTPAuth.new(TWITTER_EMAIL, TWITTER_PASSWORD)
      return Twitter::Base.new(httpauth)
    else
      oauth = Twitter::OAuth.new(TwitterAuth.config['oauth_consumer_key'], TwitterAuth.config['oauth_consumer_secret'])
      oauth.authorize_from_access(self.user.access_token, self.user.access_secret)
      return Twitter::Base.new(oauth)
    end
  end
  
  def get_last_tweet1
    client = get_twitter_client
    last_tweets = Twitter::Search.new(self.term1).per_page(1).fetch().results
    (last_tweets.size > 0) ? last_tweets.first.id : 0
  end
  
  def get_last_tweet2
    client = get_twitter_client
    last_tweets = Twitter::Search.new(self.term2).per_page(1).fetch().results
    (last_tweets.size > 0) ? last_tweets.first.id : 0
  end
  
  def term1_timeline
    begin
      client = get_twitter_client
      max_results = self.race_to - count1
      Twitter::Search.new(self.term1).since(self.last_tweet1).per_page(max_results).page(1).fetch().results
    rescue Twitter::TwitterError => e
      nil
    end
  end
  
  def term2_timeline
    begin
      client = get_twitter_client
      max_results = self.race_to - count2
      Twitter::Search.new(self.term2).since(self.last_tweet2).per_page(max_results).page(1).fetch().results
    rescue Twitter::TwitterError => e
      nil
    end
  end
  
  def initialize_last_tweets
    self.last_tweet1 = get_last_tweet1
    self.last_tweet2 = get_last_tweet2
    self.save!
  end
  
  def post_to_twitter
    client = get_twitter_client(true)
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
  
  def update_status
    begin
      search1 = term1_timeline
      if !search1.nil?
        search1.each do |t|
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 1, :tweeted_at => t.created_at)
        end
      end
      search2 = term2_timeline
      if !search2.nil?
        search2.each do |t|
          self.twitter_tweets.build(:text => t.text, :twitter_id => t.id, :author => t.from_user, :term => 2, :tweeted_at => t.created_at)
        end
      end
      self.save!
      lta1 = TwitterTweet.race_id_equals(self.id).term_equals(1).descend_by_twitter_id.first
      lta2 = TwitterTweet.race_id_equals(self.id).term_equals(2).descend_by_twitter_id.first
      self.last_tweet1 = lta1.twitter_id if !lta1.nil?
      self.last_tweet2 = lta2.twitter_id if !lta2.nil?
      self.save!
    rescue Twitter::TwitterError => e
      self.save!
    end
    
    if is_complete?
      self.update_attribute(:complete, true)
      cleanup
      post_to_twitter
    end
  end
end
