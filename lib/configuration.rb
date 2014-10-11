require "sqlite3"
require "yaml"

# nblog version string
NBLOG_VERSION = "nblog 0.1.0"

module NBlog
  
  def self.config
    @@config
  end
  
  def self.db
    @@db
  end
  
  private
    # configuration
    @@config ||= YAML.load_file File.expand_path(".", "config.yml")

    # SQLite3 database connection
    @@db ||= SQLite3::Database.new ENV['RACK_ENV'] == "test" ? ":memory:" : File.expand_path(".", @@config['dbfile'])
    # TODO: check if database was initialized
end