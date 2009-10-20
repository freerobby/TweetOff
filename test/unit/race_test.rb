require 'test_helper'
require 'shoulda'

class RaceTest < Test::Unit::TestCase
  should_validate_presence_of :term1
  should_validate_presence_of :term2
  should_validate_presence_of :last_tweet1
  should_validate_presence_of :last_tweet2
  should_validate_numericality_of :count1
  should_validate_numericality_of :count2
  should_validate_numericality_of :race_to
  
  context "with findable search terms" do
    setup do
      @race = Race.create(:term1 => "twitter", :term2 => "facebook")
      @race.save!
    end
    should "find an initial last tweet for each term" do
      assert(@race.last_tweet1.to_i > 0)
      assert(@race.last_tweet2.to_i > 0)
    end
    should "successfully execute a race" do
      @race.go!
    end
  end
  context "without findable search terms" do
    setup do
      @race = Race.create(:term1 => "askdfjhf23fhwfh2398fh238fh", :term2 => "283f238f8j23f8h2fhdjf2")
    end
    should "default to 0 for last tweet for each term" do
      assert_equal(@race.last_tweet1.to_i, 0)
      assert_equal(@race.last_tweet2.to_i, 0)
    end
  end
end
