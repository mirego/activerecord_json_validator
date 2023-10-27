# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'active_support/all'
require 'rspec'
require 'support/database/database_adapter'

adapter = case ENV['DB_ADAPTER']
            when 'mysql'
              require 'support/database/mysql_adapter'
              'mysql'
            else
              require 'pg'
              require 'support/database/postgresql_adapter'
              'postgresql'
          end

require 'activerecord_json_validator'

# Require our macros and extensions
Dir[File.expand_path('../spec/support/macros/**/*.rb', __dir__)].map(&method(:require))

RSpec.configure do |config|
  # Include our macros
  config.include DatabaseMacros
  config.include ModelMacros

  config.before :each do
    setup_database(adapter: adapter, database: 'activerecord_json_validator_test')
  end
end
