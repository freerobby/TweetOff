# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  #before_filter :basic_authenticate if RAILS_ENV == "production"

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def basic_authenticate
    # Given this username, return the cleartext password (or nil if not found)
    authenticate_or_request_with_http_basic("TweetOff!") do |username, password|
      username == "robby" and password == "tweetoff"
    end
  end
end
