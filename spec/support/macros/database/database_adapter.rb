class DatabaseAdapter
  def initialize(opts = {})
    @database = opts[:database]
  end

  def establish_connection!
    ActiveRecord::Base.establish_connection(database_configuration)
  end

  def reset_database!
  end

  def cleanup!
  end
end
