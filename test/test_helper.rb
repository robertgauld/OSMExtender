# Generate test coverage report
if Gem::Specification::find_all_by_name('simplecov').any?
  require 'simplecov'
  SimpleCov.coverage_dir(File.join('tmp', 'coverage'))
  SimpleCov.command_name 'test'
  SimpleCov.merge_timeout 1800 # Half an hour
  SimpleCov.start 'rails'
  require 'coveralls' and Coveralls.wear_merged!('rails') if ENV['TRAVIS']
end


# Origonal top of file
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Cause an error if any test causes a real web request
# This should both speed up tests and ensure that our tests cover all remote requests
FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https://coveralls.io] # Allow coveralls to report coverage

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
