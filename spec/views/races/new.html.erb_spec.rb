require 'spec_helper'

describe "/races/new.html.erb" do
  include RacesHelper

  before(:each) do
    assigns[:race] = stub_model(Race,
      :new_record? => true,
      :term1 => "value for term1",
      :term2 => "value for term2",
      :race_to => 1,
      :last_tweet1 => 0,
      :last_tweet2 => 0
    )
    
    FakeWeb.register_uri(:get, "http://search.twitter.com/trends/current.json", :body => FakeTrendsJSON) # Don't make call for Twitter trends
  end

  it "renders new race form with term1, term2 and race_to" do
    render

    response.should have_tag("form[action=?][method=post]", races_path) do
      with_tag("input#race_term1[name=?]", "race[term1]")
      with_tag("input#race_term2[name=?]", "race[term2]")
      with_tag("input#race_race_to[name=?]", "race[race_to]")
    end
  end
end
