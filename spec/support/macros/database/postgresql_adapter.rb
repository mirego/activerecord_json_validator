# frozen_string_literal: true

require_relative 'database_adapter'

class PostgresqlAdapter < DatabaseAdapter
  def database_configuration
    {
      adapter: 'postgresql',
      database: @database,
      user: 'postgres',
      schema_search_path: 'public'
    }
  end

  def reset_database!
    ActiveRecord::Base.connection.execute('drop schema public cascade;')
    ActiveRecord::Base.connection.execute('create schema public;')
  end
end
