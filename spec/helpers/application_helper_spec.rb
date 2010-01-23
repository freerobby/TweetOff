require 'spec_helper'

describe ApplicationHelper do
  describe "complete_distance_of_time_in_words()" do
    before :all do
      @time = Time.now
    end
    def call(to)
      helper.complete_distance_of_time_in_words(@time, to)
    end
    it "should accurately identify singular single-unit measurements" do
      call(@time + 1.second).should == "1 second"
      call(@time + 1.minute).should == "1 minute"
      call(@time + 1.hour).should == "1 hour"
      call(@time + 1.day).should == "1 day"
      call(@time + 1.week).should == "1 week"
    end
    it "should accurately identify plural single-unit measurements" do
      call(@time + 8.seconds).should == "8 seconds"
      call(@time + 7.minutes).should == "7 minutes"
      call(@time + 6.hours).should == "6 hours"
      call(@time + 5.days).should == "5 days"
      call(@time + 4.weeks).should == "4 weeks"
    end
    it "should accurately identify multi-unit measurements" do
      call(@time + 3.seconds + 8.minutes + 4.days).should == "4 days, 8 minutes, 3 seconds"
      call(@time + 9.seconds + 2.weeks).should == "2 weeks, 9 seconds"
      call(@time + 17.seconds + 4.minutes + 2.hours + 3.days + 2.weeks).should == "2 weeks, 3 days, 2 hours, 4 minutes, 17 seconds"
    end
  end
end
