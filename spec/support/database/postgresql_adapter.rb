# frozen_string_literal: true

require 'pg'
require_relative 'database_adapter'

class PostgresqlAdapter < DatabaseAdapter
  def reset_database!
    ActiveRecord::Base.connection.execute('drop schema public cascade;')
    ActiveRecord::Base.connection.execute('create schema public;')
  end

  def establish_connection!
    ActiveRecord::Base.establish_connection(
      ENV.fetch(
        'DATABASE_URL',
        'postgres://postgres@localhost/activerecord_json_validator_test'
      )
    )
  end
end
