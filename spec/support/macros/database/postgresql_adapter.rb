# frozen_string_literal: true

require_relative 'database_adapter'

class PostgresqlAdapter < DatabaseAdapter
  def reset_database!
    ActiveRecord::Base.connection.execute('drop schema public cascade;')
    ActiveRecord::Base.connection.execute('create schema public;')
  end
end
