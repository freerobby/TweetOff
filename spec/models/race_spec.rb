require 'spec_helper'
require 'factory_girl'
Factory.find_definitions
describe Race do
  before(:each) do    
    @tweets_twitter_vs_facebook = [
      {
        :twitter_id => 90000000000,
        :text => "I just signed up for twitter!",
        :author => "papelbuns",
        :tweeted_at=> 1.second.from_now,
        :term => 1
      },
      {
        :twitter_id => 90000000001,
        :text => "I just signed up for Facebook!",
        :author => "freerobby",
        :tweeted_at=> 1.second.from_now,
        :term => 2
      },
      {
        :twitter_id => 90000000005,
        :text => "I just signed up for Facebook and Twitter!",
        :author => "papelbuns",
        :tweeted_at=> 5.seconds.from_now,
        :term => 1
      },
      {
        :twitter_id => 90000000005,
        :text => "I just signed up for Facebook and Twitter!",
        :author => "papelbuns",
        :tweeted_at=> 5.seconds.from_now,
        :term => 2
      },
      {
        :twitter_id => 90000000009,
        :text => "I hate Facebook!",
        :author => "ev",
        :tweeted_at=> 12.seconds.from_now,
        :term => 2
      },
      {
        :twitter_id => 90000000010,
        :text => "I love Twitter!",
        :author => "jason",
        :tweeted_at=> 14.seconds.from_now,
        :term => 1
      },
      {
        :twitter_id => 90000000015,
        :text => "Twitter rocks!",
        :author => "freerobby",
        :tweeted_at=> 15.seconds.from_now,
        :term => 1
      },
      {
        :twitter_id => 90000000020,
        :text => "Facebook is meh.",
        :author => "freerobby",
        :tweeted_at=> 20.seconds.from_now,
        :term => 2
      }
    ]
    @stream_twitter = [
      {
        :id => 90000000000,
        :text => "I just signed up for twitter!",
        :from_user => "papelbuns",
        :created_at=> 1.second.from_now
      },
      {
        :id => 90000000005,
        :text => "I just signed up for Facebook and Twitter!",
        :from_user => "papelbuns",
        :created_at=> 5.seconds.from_now
      },
      {
        :id => 90000000010,
        :text => "I love Twitter!",
        :from_user => "jason",
        :created_at=> 10.seconds.from_now
      },
      {
        :id => 90000000015,
        :text => "Twitter rocks!",
        :from_user => "freerobby",
        :created_at=> 20.seconds.from_now
      }
    ]
    @stream_facebook = [
      {
        :id => 90000000001,
        :text => "I just signed up for Facebook!",
        :from_user => "freerobby",
        :created_at=> 1.second.from_now
      },
      {
        :id => 90000000005,
        :text => "I just signed up for Facebook and Twitter!",
        :from_user => "papelbuns",
        :created_at=> 5.seconds.from_now
      },
      {
        :id => 90000000009,
        :text => "I hate Facebook!",
        :from_user => "ev",
        :created_at=> 12.seconds.from_now
      },
      {
        :id => 90000000020,
        :text => "Facebook is meh.",
        :from_user => "freerobby",
        :created_at=> 15.seconds.from_now
      },
    ]
    
    @twitter_vs_facebook = Factory.build(:twitter_vs_facebook)
    @twitter_vs_facebook.stub!(:get_last_tweet1).and_return(@stream_twitter.last[:id])
    @twitter_vs_facebook.stub!(:get_last_tweet2).and_return(@stream_facebook.last[:id])
    @twitter_vs_facebook.save!
    
    @tweets_twitter_vs_facebook.each do |t|
      @twitter_vs_facebook.twitter_tweets.build(t)
    end
    @twitter_vs_facebook.save!
  end
  
  describe "model functions" do
    describe "began_at()" do
      it "should begin when race is created" do
        @twitter_vs_facebook.began_at.should == @twitter_vs_facebook.created_at
      end
    end
    
    describe "duration()" do
      it "should be the time between the first tweet in the race and the last tweet in the race" do
        @twitter_vs_facebook.duration.should be_close 19.seconds, 1.second
      end
    end
  
    describe "complete?()" do
      it "should be true if count1 >= race_to" do
        @twitter_vs_facebook.stub!(:count1).and_return(8)
        @twitter_vs_facebook.stub!(:race_to).and_return(5)
        @twitter_vs_facebook.complete?.should == true
      end
      it "should be true if count2 >= race_to" do
        @twitter_vs_facebook.stub!(:count2).and_return(8)
        @twitter_vs_facebook.stub!(:race_to).and_return(5)
        @twitter_vs_facebook.complete?.should == true
      end
      it "should be false if count1 < race_to and count2 < race_to" do
        @twitter_vs_facebook.stub!(:count1).and_return(8)
        @twitter_vs_facebook.stub!(:count2).and_return(6)
        @twitter_vs_facebook.stub!(:race_to).and_return(10)
        @twitter_vs_facebook.complete?.should == false
      end
    end
  
    describe "count1()" do
      it "should equal the number of items in twitter_tweets where term=1" do
        @twitter_vs_facebook.count1.should == 4
      end
    end
  
    describe "count2()" do
      it "should equal the number of items in twitter_tweets where term=2" do
        @twitter_vs_facebook.count2.should == 4
      end
    end
  
    describe "link_to_show" do
      before do
        ::Bitly::Client.any_instance.stubs(:shorten).returns(BitlyShortURLContainer.new)
      end
      it "should be a bit.ly link" do
        @twitter_vs_facebook.link_to_show.should include_text("http://bit.ly/")
      end
      it "should be proper bit.ly length" do
        @twitter_vs_facebook.link_to_show.size.should == "http://bit.ly/".size + 6
      end
    end
  
    describe "loser()" do
      it "should return 0 when winner is 0" do
        @twitter_vs_facebook.stub!(:winner).and_return(0)
        @twitter_vs_facebook.loser.should == 0
      end
      it "should return 1 when winner is 2" do
        @twitter_vs_facebook.stub!(:winner).and_return(2)
        @twitter_vs_facebook.loser.should == 1
      end
      it "should return 2 when winner is 1" do
        @twitter_vs_facebook.stub!(:winner).and_return(1)
        @twitter_vs_facebook.loser.should == 2
      end
    end
  
    describe "winner()" do
      it "should be 1 if count1 > count2" do
        @twitter_vs_facebook.stub!(:count1).and_return(10)
        @twitter_vs_facebook.stub!(:count2).and_return(5)
        @twitter_vs_facebook.winner.should == 1
      end
      it "should be 2 if count2 > count1" do
        @twitter_vs_facebook.stub!(:count1).and_return(5)
        @twitter_vs_facebook.stub!(:count2).and_return(10)
        @twitter_vs_facebook.winner.should == 2
      end
      it "shoudl be 0 if count1 == count2" do
        @twitter_vs_facebook.stub!(:count1).and_return(10)
        @twitter_vs_facebook.stub!(:count2).and_return(10)
        @twitter_vs_facebook.winner.should == 0
      end
    end
  
    describe "winning_term()" do
      it "should return term1 when term1 wins" do
        @twitter_vs_facebook.stub!(:winner).and_return(1)
        @twitter_vs_facebook.winning_term.should == @twitter_vs_facebook.term1
      end
      it "should return term2 when term2 wins" do
        @twitter_vs_facebook.stub!(:winner).and_return(2)
        @twitter_vs_facebook.winning_term.should == @twitter_vs_facebook.term2
      end
      it "should return nobody in the event of a tie" do
        @twitter_vs_facebook.stub!(:winner).and_return(0)
        @twitter_vs_facebook.winning_term.should == "Nobody"
      end
    end
  
    describe "ended_at()" do
      it "should return the time of the last tweet in the race" do
        @twitter_vs_facebook.ended_at.should == @twitter_vs_facebook.twitter_tweets.last.tweeted_at
      end
    end
    
    describe "go!()" do
      it "should call update status if the race is not over and we've passed the twitter refresh interval" do
        @twitter_vs_facebook.stub!(:update_status)
        @twitter_vs_facebook.stub!(:complete?).and_return(false)
        @twitter_vs_facebook.stub!(:updated_at).and_return(Time.now - 1.day)
        @twitter_vs_facebook.should_receive(:update_status).exactly(:once)
        @twitter_vs_facebook.go!
      end
      
      it "should not call update status if the race is over" do
        @twitter_vs_facebook.stub!(:complete?).and_return(true)
        @twitter_vs_facebook.should_not_receive(:update_status)
        @twitter_vs_facebook.go!
      end
      
      it "should not call update_status if we're within the twitter refresh interval" do
        @twitter_vs_facebook.stub!(:udpated_at).and_return(Time.now - 1.day)
        @twitter_vs_facebook.should_not_receive(:update_status)
        @twitter_vs_facebook.go!
      end
    end
  end
  
  it "should find the most recent tweet for each term1 and term2" do
    @twitter_vs_facebook.last_tweet1.should > 0
    @twitter_vs_facebook.last_tweet2.should > 0
  end
  
  it "should set last_tweet1 or last_tweet2 to zero if the tweet cannot be found" do
    Race.any_instance.stubs(:get_twitter_client)
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=Fox", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.007415,"query":"Fox"}')
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=CNN", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.007415,"query":"CNN"}')
    @empty_tweets = Race.create(:term1 => "Fox", :term2 => "CNN", :race_to => 10)
    @empty_tweets.last_tweet1.should == 0
    @empty_tweets.last_tweet2.should == 0
  end
  
end