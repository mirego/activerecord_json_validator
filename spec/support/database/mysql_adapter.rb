# frozen_string_literal: true

require_relative 'database_adapter'

class MysqlAdapter < DatabaseAdapter
  def reset_database!
    ActiveRecord::Base.connection.execute("SELECT concat('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '#{database}';")
  end

  def establish_connection!
    ActiveRecord::Base.establish_connection(
      ENV.fetch(
        'DATABASE_URL',
        'mysql2://root:@127.0.0.1:3306/activerecord_json_validator_test?pool=5'
      )
    )
  end
end
