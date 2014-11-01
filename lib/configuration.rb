require 'sqlite3'
require 'yaml'

# nblog version string
NBLOG_VERSION = 'nblog 0.1.5'

# nblog main module.
module NBlog
  class << self
    # Returns the user configuration (i.e. +config.yml+).
    # @return [Hash] containing the user config
    attr_reader :config

    # Returns the SQLite3 database connection.
    # @return [SQLite3::Database] currently used database
    attr_reader :db
  end

  private

  # configuration
  @config ||= YAML.load_file File.expand_path('../../config.yml', __FILE__)

  # SQLite3 database connection
  @db ||= SQLite3::Database.new(if ENV['RACK_ENV'] == 'test'
                                  ':memory:'
                                else
                                  File.expand_path(
                                    "../../#{@config['dbfile']}", __FILE__)
                                end)
  # TODO: check if database was initialized
end
