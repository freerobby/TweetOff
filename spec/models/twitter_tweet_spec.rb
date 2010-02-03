require 'spec_helper'
require 'factory_girl'
Factory.find_definitions
describe TwitterTweet do
  describe "validations" do
    before do
      FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Twitter&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Twitter"}')
      FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Facebook&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Facebook"}')
      race = Factory.create :twitter_vs_facebook
      @valid_attributes = {
        :race_id => race.id,
        :author => "Author",
        :text => "This is the tweet text",
        :twitter_id => 23732,
        :term => 1,
        :tweeted_at => 1.hour.ago
      }
    end
    it "should have text" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:text => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
    end
    it "should have an author" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:author => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
    end
    it "should have a twitter_id" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:twitter_id => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
    end
    it "should be attached to a race" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:race_id => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
    end
    it "should have a term value of 1 or 2" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:term => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:term => 0}))
      }.should raise_error ActiveRecord::RecordInvalid
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:term => 3}))
      }.should raise_error ActiveRecord::RecordInvalid
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:term => 1}))
      }.should_not raise_error
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:term => 2}))
      }.should_not raise_error
    end
    it "should have a tweeted_at date" do
      lambda {
        TwitterTweet.create!(@valid_attributes.merge({:tweeted_at => nil}))
      }.should raise_error ActiveRecord::RecordInvalid
    end
    it "should pass with valid attributes" do
      lambda {
        TwitterTweet.create!(@valid_attributes)
      }.should_not raise_error      
    end
  end
end
