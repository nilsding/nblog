require "sqlite3"
require "yaml"

# nblog version string
NBLOG_VERSION = "nblog 0.1.4"

module NBlog
  
  # Returns the user configuration (i.e. +config.yml+).
  # @return [Hash] containing the user config
  def self.config
    @@config
  end
  
  # Returns the SQLite3 database connection.
  # @return [SQLite3::Database] currently used database
  def self.db
    @@db
  end
  
  private
    # configuration
    @@config ||= YAML.load_file File.expand_path("../../config.yml", __FILE__)

    # SQLite3 database connection
    @@db ||= SQLite3::Database.new ENV['RACK_ENV'] == "test" ? ":memory:" : File.expand_path("../../#{@@config['dbfile']}", __FILE__)
    # TODO: check if database was initialized
end
