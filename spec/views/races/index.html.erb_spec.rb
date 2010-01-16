require 'spec_helper'

describe "/races/index.html.erb" do
  include RacesHelper

  describe "filtering" do
    before do
      FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Twitter&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Twitter"}')
      FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Facebook&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Facebook"}')
      
      # Create empty races when using factories (no search results)
      Race.any_instance.stubs(:get_last_tweet1).returns(0)
      Race.any_instance.stubs(:get_last_tweet2).returns(0)
      # No need to really go through the motions.
      Race.any_instance.stubs(:update_status)
      @unfinished_1 = Factory.create :race, :term1 => "ipod", :term2 => "iphone", :race_to => 1, :complete => false
      @unfinished_2 = Factory.create :race, :term1 => "mac", :term2 => "pc", :race_to => 1, :complete => false
      @finished_1 = Factory.create :race, :term1 => "mark", :term2 => "steve", :race_to => 1, :complete => true
      @finished_2 = Factory.create :race, :term1 => "time", :term2 => "date", :race_to => 1, :complete => true
    end
    describe "all" do
      it "should render properly" do
        assigns[:search] = Race.search(:complete_equals => nil)
        assigns[:races] = assigns[:search].all
        assigns[:races].stub!(:total_pages).and_return(1)
        render
        response.should include_text race_path(@unfinished_1.id)
        response.should include_text race_path(@unfinished_2.id)
        response.should include_text race_path(@finished_1.id)
        response.should include_text race_path(@finished_2.id)
      end
    end
    describe "only complete" do
      it "should render properly" do
        assigns[:search] = Race.search(:complete_equals => 1)
        assigns[:races] = assigns[:search].all
        assigns[:races].stub!(:total_pages).and_return(1)
        render
        response.should_not include_text race_path(@unfinished_1.id)
        response.should_not include_text race_path(@unfinished_2.id)
        response.should include_text race_path(@finished_1.id)
        response.should include_text race_path(@finished_2.id)
      end
    end
    describe "only incomplete" do
      it "should render properly" do
        assigns[:search] = Race.search(:complete_equals => 0)
        assigns[:races] = assigns[:search].all
        assigns[:races].stub!(:total_pages).and_return(1)
        render
        response.should include_text race_path(@unfinished_1.id)
        response.should include_text race_path(@unfinished_2.id)
        response.should_not include_text race_path(@finished_1.id)
        response.should_not include_text race_path(@finished_2.id)
      end
    end
  end
  
end
