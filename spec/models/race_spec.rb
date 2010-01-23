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
        :text => "Facebook is meh.",
        :author => "freerobby",
        :tweeted_at=> 20.seconds.from_now,
        :term => 2
      },
      {
        :twitter_id => 90000000020,
        :text => "Twitter rocks!",
        :author => "freerobby",
        :tweeted_at=> 15.seconds.from_now,
        :term => 1
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
        :id => 90000000020,
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
        :id => 90000000011,
        :text => "I hate Facebook!",
        :from_user => "ev",
        :created_at=> 12.seconds.from_now
      },
      {
        :id => 90000000015,
        :text => "Facebook is meh.",
        :from_user => "freerobby",
        :created_at=> 15.seconds.from_now
      },
    ]
    
    @twitter_vs_facebook = Factory.build(:twitter_vs_facebook)
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Twitter&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Twitter"}')
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Facebook&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Facebook"}')
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
  
    describe "is_complete?()" do
      it "should be true if count1 >= race_to" do
        @twitter_vs_facebook.stub!(:count1).and_return(8)
        @twitter_vs_facebook.stub!(:race_to).and_return(5)
        @twitter_vs_facebook.is_complete?.should == true
      end
      it "should be true if count2 >= race_to" do
        @twitter_vs_facebook.stub!(:count2).and_return(8)
        @twitter_vs_facebook.stub!(:race_to).and_return(5)
        @twitter_vs_facebook.is_complete?.should == true
      end
      it "should be false if count1 < race_to and count2 < race_to" do
        @twitter_vs_facebook.stub!(:count1).and_return(8)
        @twitter_vs_facebook.stub!(:count2).and_return(6)
        @twitter_vs_facebook.stub!(:race_to).and_return(10)
        @twitter_vs_facebook.is_complete?.should == false
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
        @twitter_vs_facebook.twitter_tweets.count.should > 0
        @twitter_vs_facebook.ended_at.should == @twitter_vs_facebook.twitter_tweets.find_by_twitter_id(90000000015).tweeted_at
      end
    end
    
    describe "twitter_timeout_passed?()" do
      it "should return false when within interval" do
        @twitter_vs_facebook.stub!(:updated_at).and_return(Time.now - TWITTER_REFRESH_INTERVAL + 1.minute)
        @twitter_vs_facebook.twitter_timeout_passed?.should == false
      end
      it "should return true when beyond interval" do
        @twitter_vs_facebook.stub!(:updated_at).and_return(Time.now - TWITTER_REFRESH_INTERVAL - 1.minute)
        @twitter_vs_facebook.twitter_timeout_passed?.should == true
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
        @twitter_vs_facebook.stub!(:twitter_timeout_passed?).and_return(false)
        @twitter_vs_facebook.should_not_receive(:update_status)
        @twitter_vs_facebook.go!
      end
    end
  end
  
  it "should find the most recent tweet for each term1 and term2" do
    FakeWeb.clean_registry
    @twitter_vs_facebook = Factory.build(:twitter_vs_facebook)
    @twitter_vs_facebook.stub!(:get_last_tweet1).and_return(@stream_twitter.last[:id])
    @twitter_vs_facebook.stub!(:get_last_tweet2).and_return(@stream_facebook.last[:id])
    @twitter_vs_facebook.save!
    @tweets_twitter_vs_facebook.each do |t|
      @twitter_vs_facebook.twitter_tweets.build(t)
    end
    @twitter_vs_facebook.save!    
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
  
  describe "private methods" do
    describe "generate_twitter_status()" do
      before do
        # Create empty races when using factories (no search results)
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        # No need to really go through the motions.
        Race.any_instance.stubs(:update_status)
        # Assume we are not bailing due to hammering Twitter too much.
        Race.any_instance.stubs(:twitter_timeout_passed?).returns(true)
      end
      describe "user-owned" do
        before do
          user = Factory.create :user, :login => "user", :twitter_id => "237237283"
          
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 10, :user => user
          @race.stub!(:duration).and_return(1.hour)
          @race.stub!(:link_to_show).and_return("http://link.to/return")
        end
        it "should generate properly on draw" do
          @race.stub!(:count1).and_return(10)
          @race.stub!(:count2).and_return(10)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should include_text "It's a draw!"
          generated_status.should include_text "@user"
        end
        it "should generate properly on term1 winner" do
          @race.stub!(:count1).and_return(10)
          @race.stub!(:count2).and_return(5)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should match /ipod.*10.*iphone.*5/
          generated_status.should include_text "@user"
        end
        it "should generate properly on term2 winner" do
          @race.stub!(:count1).and_return(5)
          @race.stub!(:count2).and_return(10)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should match /iphone.*10.*ipod.*5/
          generated_status.should include_text "@user"
        end
      end
      describe "anonymous" do
        before do
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 10
          @race.stub!(:duration).and_return(1.hour)
          @race.stub!(:link_to_show).and_return("http://link.to/return")
        end
        it "should generate properly on draw" do
          @race.stub!(:count1).and_return(10)
          @race.stub!(:count2).and_return(10)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should include_text "It's a draw!"
          generated_status.should_not include_text "@"
        end
        it "should generate properly on term1 winner" do
          @race.stub!(:count1).and_return(10)
          @race.stub!(:count2).and_return(5)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should match /ipod.*10.*iphone.*5/
          generated_status.should_not include_text "@"
        end
        it "should generate properly on term2 winner" do
          @race.stub!(:count1).and_return(5)
          @race.stub!(:count2).and_return(10)
          generated_status = @race.send(:generate_twitter_status)
          generated_status.should match /iphone.*10.*ipod.*5/
          generated_status.should_not include_text "@"
        end
      end
    end
    describe "get_twitter_client()" do
      before do
        # Create empty races when using factories (no search results)
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        # No need to really go through the motions.
        Race.any_instance.stubs(:update_status)
      end
      describe "signed in via oauth" do
        before do
          user = Factory.create :user, :login => "user", :twitter_id => "237237283"
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 10, :user => user
        end
        it "should return oauth client by default" do
          @mock_oauth = mock_model(Twitter::OAuth)
          Twitter::OAuth.stub(:new).once.and_return(@mock_oauth)
          @mock_oauth.stub!(:authorize_from_access)
          @race.send(:get_twitter_client)
        end
        it "should return http client with tweetoff_account override" do
          @mock_httpauth = mock_model(Twitter::HTTPAuth)
          Twitter::HTTPAuth.stub(:new).once.and_return(@mock_httpauth)
          @race.send(:get_twitter_client, true)
        end
      end
      describe "not signed in via oauth" do
        before do
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 10
        end
        it "should return httpauth client" do
          @mock_httpauth = mock_model(Twitter::HTTPAuth)
          Twitter::HTTPAuth.stub(:new).once.and_return(@mock_httpauth)
          @race.send(:get_twitter_client)
        end
      end
    end
    
    describe "get_last_tweet1() and get_last_tweet2()" do
      describe "get_last_tweet1" do
        before do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=iphone", :body => '{"results":[],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=iphone","next_page":"?page=2&max_id=7852748889&rpp=1&q=iphone","results_per_page":1,"page":1,"completed_in":0.015028,"query":"iphone"}')
        end
        it "should return the last tweet mentioning term 1" do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=ipod", :body => '{"results":[{"profile_image_url":"http://s.twimg.com/a/1263516095/images/default_profile_4_normal.png","created_at":"Sun, 17 Jan 2010 04:42:48 +0000","from_user":"antoinejaquez62","to_user_id":null,"text":"Apple iPod Nano 5th... Lowest Prices @ http://bit.ly/8GC4P6","id":7852748889,"from_user_id":81204093,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"}],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=ipod","next_page":"?page=2&max_id=7852748889&rpp=1&q=ipod","results_per_page":1,"page":1,"completed_in":0.015028,"query":"ipod"}')
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
          mock_client = mock_model(Twitter::Base)
          @race.send(:get_last_tweet1).should == 7852748889
        end
        it "should return 0 on empty stream" do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=ipod", :body => '{"results":[],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=ipod","next_page":"?page=2&max_id=7852748889&rpp=1&q=ipod","results_per_page":1,"page":1,"completed_in":0.015028,"query":"ipod"}')
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
          mock_client = mock_model(Twitter::Base)
          @twitter_vs_facebook.send(:get_last_tweet1).should == 0
        end
      end
      describe "get_last_tweet2" do
        before do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=ipod", :body => '{"results":[{"profile_image_url":"http://s.twimg.com/a/1263516095/images/default_profile_4_normal.png","created_at":"Sun, 17 Jan 2010 04:42:48 +0000","from_user":"antoinejaquez62","to_user_id":null,"text":"Apple iPod Nano 5th... Lowest Prices @ http://bit.ly/8GC4P6","id":7852748889,"from_user_id":81204093,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"}],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=ipod","next_page":"?page=2&max_id=7852748889&rpp=1&q=ipod","results_per_page":1,"page":1,"completed_in":0.015028,"query":"ipod"}')
        end
        it "should return the last tweet mentioning term 1" do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=iphone", :body => '{"results":[{"profile_image_url":"http://s.twimg.com/a/1263516095/images/default_profile_4_normal.png","created_at":"Sun, 17 Jan 2010 04:42:48 +0000","from_user":"antoinejaquez62","to_user_id":null,"text":"Apple iphone Nano 5th... Lowest Prices @ http://bit.ly/8GC4P6","id":7852748889,"from_user_id":81204093,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"}],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=iphone","next_page":"?page=2&max_id=7852748889&rpp=1&q=iphone","results_per_page":1,"page":1,"completed_in":0.015028,"query":"iphone"}')
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
          mock_client = mock_model(Twitter::Base)
          @race.send(:get_last_tweet2).should == 7852748889
        end
        it "should return 0 on empty stream" do
          FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?rpp=1&q=iphone", :body => '{"results":[],"max_id":7852748889,"since_id":0,"refresh_url":"?since_id=7852748889&q=iphone","next_page":"?page=2&max_id=7852748889&rpp=1&q=iphone","results_per_page":1,"page":1,"completed_in":0.015028,"query":"iphone"}')
          @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
          mock_client = mock_model(Twitter::Base)
          @twitter_vs_facebook.send(:get_last_tweet2).should == 0
        end
      end
    end
    
    
    describe "term1_timeline() and term2_timeline()" do
      before do
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 5
      end
      it "should return their respective timelines" do
        FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=iphone&page=1&rpp=5&since_id=0", :body => '{"results":[{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:44 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @esasahara Alibaba: Yahoo\'s Google Support \'Reckless\' http://bit.ly/83lRHw #WSJ #iPhone","id":7853441160,"from_user_id":30169857,"geo":null,"iso_language_code":"es","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:42 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @wx2000 #iPhone \u514d\u8d39\u8f6f\u4ef6 PetitDaiFugo Lite 1.0Category: GamesPrice: Free (iTunes)Description:It is card game &quot;&quot;Poverty&quot;&quot; that ... http://bit","id":7853440559,"from_user_id":30169857,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:41 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @whdazhe #iPhone \u514d\u8d39\u8f6f\u4ef6 PetitDaiFugo Lite 1.0Category: GamesPrice: Free (iTunes)Description:It is card game &quot;&quot;Poverty&quot;&quot; that ... http://bi","id":7853439981,"from_user_id":30169857,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/625806874/Photo_on_2010-01-11_at_22.20__6_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:41 +0000","from_user":"CBrittMaria","to_user_id":null,"text":"reading about the new iPhone 4g with video chat, i think I\'m in love again...","id":7853439963,"from_user_id":5117906,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/634731225/tumblr_kw1phnE5ip01_500_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:40 +0000","from_user":"la2bleeu","to_user_id":null,"text":"RT @merryleehyukjae: RT @anindyamalia: RT @arumm: RT @arnoldteja: #dearSBY hujan iphone /onyx dong","id":7853439329,"from_user_id":89627612,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"}],"max_id":7853441160,"since_id":0,"refresh_url":"?since_id=7853441160&q=iphone","next_page":"?page=2&max_id=7853441160&rpp=5&q=iphone","results_per_page":5,"page":1,"completed_in":0.016801,"query":"iphone"}')
        FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?page=1&rpp=5&q=ipod&since_id=0", :body => '{"results":[{"profile_image_url":"http://a1.twimg.com/profile_images/603481274/twitterProfilePhoto_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:08 +0000","from_user":"luckygirl20","to_user_id":16862409,"text":"@sandritangel mi ipod, mi ipod, lo olvide en un carro de un sr que me dio trajo a la casa :(","id":7853480699,"from_user_id":14560335,"to_user":"sandritangel","geo":null,"iso_language_code":"es","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/590637560/18863_1238695241553_1054418232_30721568_4073638_n_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:07 +0000","from_user":"xannakidd","to_user_id":null,"text":"I feel like going on a walk in the rain. No phone, just an ipod to get away for a second.","id":7853480274,"from_user_id":12750337,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/634615253/CB1_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:03 +0000","from_user":"LaibaBeadles","to_user_id":82854250,"text":"@LittleCBeadles  http://twitpic.com/yg6mo comment please (: I did it on my iPod.","id":7853478567,"from_user_id":89733684,"to_user":"LittleCBeadles","geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://www.tweetdeck.com/&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/450410271/Photo_2_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:03 +0000","from_user":"chadh_0427","to_user_id":null,"text":"The times i wish i had my ipod touch.","id":7853478350,"from_user_id":65242486,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;/devices&quot; rel=&quot;nofollow&quot;&gt;txt&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/414109196/n714405930_1217049_2267_normal.jpg","created_at":"Sun, 17 Jan 2010 05:07:59 +0000","from_user":"Piggalo","to_user_id":6055573,"text":"@CSI_Kat just on iPod touch let me switch to pc my friend sent it to me she said it\'s shamwow","id":7853476662,"from_user_id":25464096,"to_user":"CSI_Kat","geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitterrific.com&quot; rel=&quot;nofollow&quot;&gt;Twitterrific&lt;/a&gt;"}],"max_id":7853480699,"since_id":0,"refresh_url":"?since_id=7853480699&q=ipod","next_page":"?page=2&max_id=7853480699&rpp=5&q=ipod","results_per_page":5,"page":1,"completed_in":0.022522,"query":"ipod"}')          
        @race.send(:term1_timeline).count.should == 5
        @race.send(:term2_timeline).count.should == 5
      end
    end
    
    describe "initialize_last_tweets()" do
      it "should set each last tweet to the most recent one that can be found" do
        Race.any_instance.stubs(:get_last_tweet1).returns(5)
        Race.any_instance.stubs(:get_last_tweet2).returns(10)
        @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 5
        @race.send(:initialize_last_tweets)
        @race.last_tweet1.should == 5
        @race.last_tweet2.should == 10
      end
    end
    
    describe "post_to_twitter()" do
      before do
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        # No need to really go through the motions.
        Race.any_instance.stubs(:update_status)
        @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 5
        @race.stub!(:generate_twitter_status).and_return("Twitter status!")
        Twitter::Base.any_instance.stubs(:update)
        @mock_httpauth = mock_model(Twitter::HTTPAuth)
      end
      it "should get an HTTPAuth Twitter client" do
        Twitter::HTTPAuth.stub!(:new).once.and_return(@mock_httpauth)
        @race.send(:post_to_twitter)
      end
      it "should call update() on the client" do
        Twitter::HTTPAuth.stub!(:new).and_return(@mock_httpauth)
        @mock_httpauth.stub!(:update).once
        @race.send(:post_to_twitter)
      end
    end
    
    describe "cleanup()" do
      before do
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        # No need to really go through the motions.
        Race.any_instance.stubs(:update_status)
        @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 5
        @race.stub!(:remove_tweets_past_finish_line)
        @race.stub!(:break_tie_by_tweet_ids)
        @race.stub!(:remove_extras)
      end
      describe "remove extra tweets" do
        before do
        end
        it "should fire when term 1 count is beyond race_to" do
          @race.stub!(:count1).and_return(10)
          @race.stub!(:count2).and_return(3)
          @race.should_receive(:remove_tweets_past_finish_line).once
          @race.send(:cleanup)
        end
        it "should fire when term 2 count is beyond race_to" do
          @race.stub!(:count1).and_return(3)
          @race.stub!(:count2).and_return(10)
          @race.should_receive(:remove_tweets_past_finish_line).once
          @race.send(:cleanup)
        end
        it "should not fire if neither term is beyond race_to" do
          @race.stub!(:count1).and_return(5)
          @race.stub!(:count2).and_return(5)
          @race.should_not_receive(:remove_tweets_past_finish_line)
          @race.send(:cleanup)
        end
      end
      # This should change to a more specific tie-breaking scenario
      describe "break tie" do
        it "should fire if tweets are found for both terms" do
          @race.stub!(:count1).and_return(5)
          @race.stub!(:count2).and_return(3)
          @race.should_receive(:break_tie_by_tweet_ids).once
          @race.send(:cleanup)
        end
        it "should not fire if term1 not found" do
          @race.stub!(:count1).and_return(0)
          @race.stub!(:count2).and_return(3)
          @race.should_not_receive(:break_tie_by_tweet_ids)
          @race.send(:cleanup)
        end
        it "should not fire if term2 not found" do
          @race.stub!(:count1).and_return(5)
          @race.stub!(:count2).and_return(0)
          @race.should_not_receive(:break_tie_by_tweet_ids)
          @race.send(:cleanup)
        end
      end
      it "should remove tweets that came in after the race was won" do
        @race.should_receive(:remove_extras).once
        @race.send(:cleanup)
      end
    end
    
    # Function seems to assume only one extra tweet max?
    describe "break_tie_by_tweet_ids()" do
      describe "count1 == count2" do
        it "should remove the extra tweet" do
          @twitter_vs_facebook.count1.should == 4
          @twitter_vs_facebook.count2.should == 4
          @twitter_vs_facebook.send(:break_tie_by_tweet_ids)
          @twitter_vs_facebook.count1.should == 3
          @twitter_vs_facebook.count2.should == 4
        end
      end
      describe "count1 != count2" do
        it "should not remove anything" do
          @twitter_vs_facebook.twitter_tweets.find_by_term(2, :order => "twitter_id DESC").destroy
          @twitter_vs_facebook.count1.should == 4
          @twitter_vs_facebook.count2.should == 3
          @twitter_vs_facebook.send(:break_tie_by_tweet_ids)
          @twitter_vs_facebook.count1.should == 4
          @twitter_vs_facebook.count2.should == 3
        end
      end
    end
    
    describe "remove_extras()" do
      before do
        @twitter_vs_facebook.stub!(:race_to).and_return(4)
        @twitter_vs_facebook.stub!(:winner).and_return(2)
      end
      it "should remove any loser's tweets that came after winner won" do
        @twitter_vs_facebook.count1.should == 4
        @twitter_vs_facebook.count2.should == 4
        @twitter_vs_facebook.send(:remove_extras)
        @twitter_vs_facebook.count1.should == 3
        @twitter_vs_facebook.count2.should == 4
      end
    end
    
    #ToDo: check actual tweets instead of just the counts.
    describe "remove_tweets_past_finish_line()" do
      it "should remove any winner's tweets beyond the winning one" do
        @twitter_vs_facebook.stub!(:race_to).and_return(3)
        @twitter_vs_facebook.stub!(:winner).and_return(2)
        @twitter_vs_facebook.count2.should == 4
        @twitter_vs_facebook.send(:remove_tweets_past_finish_line)
        @twitter_vs_facebook.count2.should == 3
      end
    end
    
    describe "update_status()" do
      before do
        Race.any_instance.stubs(:get_last_tweet1).returns(0)
        Race.any_instance.stubs(:get_last_tweet2).returns(0)
        @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 5
        FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=iphone&page=1&rpp=5&since_id=0", :body => '{"results":[{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:44 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @esasahara Alibaba: Yahoo\'s Google Support \'Reckless\' http://bit.ly/83lRHw #WSJ #iPhone","id":7853441160,"from_user_id":30169857,"geo":null,"iso_language_code":"es","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:42 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @wx2000 #iPhone \u514d\u8d39\u8f6f\u4ef6 PetitDaiFugo Lite 1.0Category: GamesPrice: Free (iTunes)Description:It is card game &quot;&quot;Poverty&quot;&quot; that ... http://bit","id":7853440559,"from_user_id":30169857,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/323940395/guineapig_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:41 +0000","from_user":"uberguineapig","to_user_id":null,"text":"RT: @whdazhe #iPhone \u514d\u8d39\u8f6f\u4ef6 PetitDaiFugo Lite 1.0Category: GamesPrice: Free (iTunes)Description:It is card game &quot;&quot;Poverty&quot;&quot; that ... http://bi","id":7853439981,"from_user_id":30169857,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://apiwiki.twitter.com/&quot; rel=&quot;nofollow&quot;&gt;API&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/625806874/Photo_on_2010-01-11_at_22.20__6_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:41 +0000","from_user":"CBrittMaria","to_user_id":null,"text":"reading about the new iPhone 4g with video chat, i think I\'m in love again...","id":7853439963,"from_user_id":5117906,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/634731225/tumblr_kw1phnE5ip01_500_normal.jpg","created_at":"Sun, 17 Jan 2010 05:06:40 +0000","from_user":"la2bleeu","to_user_id":null,"text":"RT @merryleehyukjae: RT @anindyamalia: RT @arumm: RT @arnoldteja: #dearSBY hujan iphone /onyx dong","id":7853439329,"from_user_id":89627612,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"}],"max_id":7853441160,"since_id":0,"refresh_url":"?since_id=7853441160&q=iphone","next_page":"?page=2&max_id=7853441160&rpp=5&q=iphone","results_per_page":5,"page":1,"completed_in":0.016801,"query":"iphone"}')
        FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?page=1&rpp=5&q=ipod&since_id=0", :body => '{"results":[{"profile_image_url":"http://a1.twimg.com/profile_images/603481274/twitterProfilePhoto_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:08 +0000","from_user":"luckygirl20","to_user_id":16862409,"text":"@sandritangel mi ipod, mi ipod, lo olvide en un carro de un sr que me dio trajo a la casa :(","id":7853480699,"from_user_id":14560335,"to_user":"sandritangel","geo":null,"iso_language_code":"es","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/590637560/18863_1238695241553_1054418232_30721568_4073638_n_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:07 +0000","from_user":"xannakidd","to_user_id":null,"text":"I feel like going on a walk in the rain. No phone, just an ipod to get away for a second.","id":7853480274,"from_user_id":12750337,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/634615253/CB1_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:03 +0000","from_user":"LaibaBeadles","to_user_id":82854250,"text":"@LittleCBeadles  http://twitpic.com/yg6mo comment please (: I did it on my iPod.","id":7853478567,"from_user_id":89733684,"to_user":"LittleCBeadles","geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://www.tweetdeck.com/&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;"},{"profile_image_url":"http://a3.twimg.com/profile_images/450410271/Photo_2_normal.jpg","created_at":"Sun, 17 Jan 2010 05:08:03 +0000","from_user":"chadh_0427","to_user_id":null,"text":"The times i wish i had my ipod touch.","id":7853478350,"from_user_id":65242486,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;/devices&quot; rel=&quot;nofollow&quot;&gt;txt&lt;/a&gt;"},{"profile_image_url":"http://a1.twimg.com/profile_images/414109196/n714405930_1217049_2267_normal.jpg","created_at":"Sun, 17 Jan 2010 05:07:59 +0000","from_user":"Piggalo","to_user_id":6055573,"text":"@CSI_Kat just on iPod touch let me switch to pc my friend sent it to me she said it\'s shamwow","id":7853476662,"from_user_id":25464096,"to_user":"CSI_Kat","geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://twitterrific.com&quot; rel=&quot;nofollow&quot;&gt;Twitterrific&lt;/a&gt;"}],"max_id":7853480699,"since_id":0,"refresh_url":"?since_id=7853480699&q=ipod","next_page":"?page=2&max_id=7853480699&rpp=5&q=ipod","results_per_page":5,"page":1,"completed_in":0.022522,"query":"ipod"}')
      end
      it "should get the timelines correctly." do
        @race.should_receive(:term1_timeline)
        @race.should_receive(:term2_timeline)
        @race.send(:update_status)
      end
      it "should add the timeline tweets to the race" do
        @race.stub!(:is_complete?).and_return(false)
        @race.count1.should == 0
        @race.count2.should == 0
        @race.send(:update_status)
        @race.count1.should == 5
        @race.count2.should == 5
      end
      describe "is_complete? true" do
        it "should set complete to true" do
          @race.stub!(:is_complete?).and_return(true)
          @race.stub!(:cleanup)
          @race.stub!(:post_to_twitter)
          @race.send(:update_status)
          
          @race.complete.should == true
        end
        it "should run cleanup" do
          @race.stub!(:is_complete?).and_return(true)
          @race.stub!(:cleanup)
          @race.stub!(:post_to_twitter)
          @race.should_receive(:cleanup).once
          @race.send(:update_status)
        end
        it "should post to twitter" do
          @race.stub!(:is_complete?).and_return(true)
          @race.stub!(:cleanup)
          @race.stub!(:post_to_twitter)
          @race.should_receive(:post_to_twitter).once
          @race.send(:update_status)
        end
      end
    end

  end
  
end
