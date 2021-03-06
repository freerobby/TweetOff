# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

require 'fakeweb'
require 'json'
require 'will_paginate'

FakeWeb.allow_net_connect = false

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}
Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  config.after :each do
    mocha_teardown
  end
end

# Spec::Runner.configuration.before(:all, :behaviour_type => :controller) do
#   @integrate_views = true
# end

FakeTrendsJSON = '{"trends":{"2009-12-30 03:00:38":[{"name":"#nowplaying","query":"#nowplaying"},{"name":"#iloveitwhen","query":"#iloveitwhen"},{"name":"#jonasmemories","query":"#jonasmemories"},{"name":"Stop Misspelling","query":"\"Stop Misspelling\""},{"name":"NYE","query":"NYE"},{"name":"Words You Need","query":"\"Words You Need\""},{"name":"Avatar","query":"Avatar"},{"name":"Pro Bowl","query":"\"Pro Bowl\""},{"name":"#RIPTheRev","query":"#RIPTheRev"},{"name":"Kennedy Center","query":"\"Kennedy Center\""}]},"as_of":1262142038}'

class BitlyShortURLContainer
  def short_url
    "http://bit.ly/" + ActiveSupport::SecureRandom.hex(3).upcase
  end
end