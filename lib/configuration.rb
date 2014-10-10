require "sqlite3"
require "yaml"

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
    @@db ||= SQLite3::Database.new File.expand_path(".", @@config['dbfile'])
end