require "sqlite3"
require "yaml"

# nblog version string
NBLOG_VERSION = "nblog 0.1.1"

module NBlog
  
  def self.config
    @@config
  end
  
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
