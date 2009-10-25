require 'spec_helper'

describe Race do
  before(:each) do
    @valid_attributes = {
      :term1 => "value for term1",
      :term2 => "value for term2",
      :race_to => 5,
      :last_tweet1 => 0,
      :last_tweet2 => 0
    }
  end

  it "should create a new instance given valid attributes" do
    Race.create!(@valid_attributes)
  end
end
