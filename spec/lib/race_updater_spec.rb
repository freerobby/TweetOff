require 'spec_helper'

describe RaceUpdater do
  before do
    # Create empty races when using factories (no search results)
    Race.any_instance.stubs(:get_last_tweet1).returns(0)
    Race.any_instance.stubs(:get_last_tweet2).returns(0)
    
    # No need to really go through the motions.
    Race.any_instance.stubs(:update_status)
    
    # Assume we are not bailing due to hammering Twitter too much.
    Race.any_instance.stubs(:twitter_timeout_passed?).returns(true)
  end
  
  describe "#update_all!()" do
    before do
      @unfinished_1 = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
      @unfinished_2 = Factory.create :race, :term1 => "mac", :term2 => "pc", :race_to => 1
      @finished_1 = Factory.create :race, :term1 => "mark", :term2 => "steve", :race_to => 1
      @finished_2 = Factory.create :race, :term1 => "time", :term2 => "date", :race_to => 1
      
      @unfinished_1.stub!(:complete?).and_return(false)
      @unfinished_2.stub!(:complete?).and_return(false)
      @finished_1.stub!(:complete?).and_return(true)
      @finished_2.stub!(:complete?).and_return(true)
      
      Race.stubs(:find).with(@unfinished_1.id).returns(@unfinished_1)
      Race.stubs(:find).with(@unfinished_2.id).returns(@unfinished_2)
      Race.stubs(:find).with(@finished_1.id).returns(@finished_1)
      Race.stubs(:find).with(@finished_2.id).returns(@finished_2)
      Race.stubs(:find).with(:all).returns([@unfinished_1, @unfinished_2, @finished_1, @finished_2])
    end
    after do
      RaceUpdater::update_all!
    end
    it "should update all unfinished races" do
      @unfinished_1.should_receive(:update_status).once
      @unfinished_2.should_receive(:update_status).once
    end
    it "should not update any finished races" do
      @finished_1.should_not_receive(:update_status)
      @finished_2.should_not_receive(:update_status)
    end
  end
  describe "#update!()" do
    before do
      @race = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1
      
      # We need our external find call to return our same instance var
      Race.stubs(:find).with(@race.id).returns(@race)
    end
    it "should update the race if it is not finished" do
      # Prerequisites for "update_status" to fire from within go!()
      @race.stub!(:complete?).and_return(false)
      
      @race.should_receive(:update_status).once
      RaceUpdater::update!(@race.id)
    end
    it "should not update the race if it is finished" do
      # Should prevent "update_status" from firing in go!()
      @race.stub!(:complete?).and_return(true)
      
      @race.should_not_receive(:update_status)
      RaceUpdater::update!(@race.id)
    end
  end
end