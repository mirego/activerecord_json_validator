$:.unshift File.expand_path('../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

require 'active_support/all'
require 'rspec'
require 'pg'

require 'activerecord_json_validator'

# Require our macros and extensions
Dir[File.expand_path('../../spec/support/macros/**/*.rb', __FILE__)].map(&method(:require))

RSpec.configure do |config|
  # Include our macros
  config.include DatabaseMacros
  config.include ModelMacros

  config.before :each do
    adapter = 'postgresql'
    setup_database(adapter: adapter, database: 'activerecord_json_validator_test')
  end
end
