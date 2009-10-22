include TwitterSearch

class TwitterTweet < ActiveRecord::Base
  belongs_to :race
  
  validates_presence_of :text
  validates_presence_of :twitter_id
  validates_presence_of :author
  validates_numericality_of :race_id, :only_integer => true, :allow_nil => false
  validates_numericality_of :term, :in => 1..2, :allow_nil => false
  validates_presence_of :tweeted_at
end
