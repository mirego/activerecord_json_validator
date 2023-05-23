# frozen_string_literal: true

class DatabaseAdapter
  def initialize(opts = {})
    @database = opts[:database]
  end

  def establish_connection!
    ActiveRecord::Base.establish_connection(ENV.fetch('DATABASE_URL', 'postgres://postgres@localhost/activerecord_json_validator_test'))
  end
end
