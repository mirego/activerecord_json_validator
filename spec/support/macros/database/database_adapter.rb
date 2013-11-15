class DatabaseAdapter
  def initialize(opts = {})
    @database = opts[:database]
  end

  def establish_connection!
    ActiveRecord::Base.establish_connection(database_configuration)
  end
end
