# frozen_string_literal: true

require 'active_record'
class DatabaseAdapter
  attr_accessor :database

  def initialize(opts = {})
    self.database = opts[:database]
  end

  def reset_database!
    raise 'Define reset_database! in subclasses!'
  end

  def establish_connection!
    raise 'Define establish_connection! in subclasses!'
  end
end
