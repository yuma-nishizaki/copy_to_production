$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'copy_to_production'
require 'pry'

begin
  require 'rails'
rescue LoadError
end

require 'bundler/setup'
Bundler.require
require 'active_record'
require 'database_cleaner'

if defined? Rails
  require 'paperclip'
  require 'fake_app/rails_app'
  require 'rspec/rails'
end
if defined? Sinatra
  require 'spec_helper_for_sinatra'
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# RSpec.configure do |config|
#   config.mock_with :rr
#   config.filter_run_excluding :generator_spec => true if !ENV['GENERATOR_SPEC']
# end
