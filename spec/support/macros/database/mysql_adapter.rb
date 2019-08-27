# frozen_string_literal: true

require_relative 'database_adapter'

class Mysql2Adapter < DatabaseAdapter
  def database_configuration
    {
      adapter: 'mysql2',
      database: @database,
      username: 'travis',
      encoding: 'utf8'
    }
  end

  def reset_database!
    ActiveRecord::Base.connection.execute("SELECT concat('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '#{@database}';")
  end
end
