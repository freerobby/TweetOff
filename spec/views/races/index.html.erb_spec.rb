require 'spec_helper'

describe "/races/index.html.erb" do
  include RacesHelper

  before do
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Twitter&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Twitter"}')
    FakeWeb.register_uri(:get, "http://search.twitter.com/search.json?q=Facebook&rpp=1", :body => '{"results":[],"max_id":-1,"since_id":0,"results_per_page":15,"page":1,"completed_in":0.006922,"query":"Facebook"}')
    
    Factory.create :twitter_vs_facebook
    races = Race.all
    races.stub!(:total_pages).and_return(1)
    assigns[:races] = races
  end

  it "renders a list of races" do
    render
    response.should include_text "Twitter"
    response.should include_text "Facebook"
  end
end
