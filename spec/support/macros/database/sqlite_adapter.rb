require_relative 'database_adapter'

class Sqlite3Adapter < DatabaseAdapter
  def database_configuration
    {
      adapter: 'sqlite3',
      database: "#{@database}.sqlite",
      username: 'travis',
      encoding: 'utf8'
    }
  end

  def cleanup!
    `rm #{@database}.sqlite` if File.exists?("#{@database}.sqlite")
  end
end
