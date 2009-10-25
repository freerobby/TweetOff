require 'spec_helper'

describe "/races/show.html.erb" do
  include RacesHelper
  before(:each) do
    assigns[:race] = @race = stub_model(Race,
      :term1 => "value for term1",
      :term2 => "value for term2",
      :race_to => 1,
      :last_tweet1 => 0,
      :last_tweet2 => 0
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ term1/)
    response.should have_text(/value\ for\ term2/)
    response.should have_text(/1/)
    response.should have_text(//)
    response.should have_text(//)
  end
end
