require "highline/import"
require "sqlite3"
require "bcrypt"
require "yaml"

# configuration
$config ||= YAML.load_file File.expand_path(".", "config.yml")

# SQLite3 database connection
$db ||= SQLite3::Database.new File.expand_path(".", $config['dbfile'])

module NBlog
  class InteractiveShell
    # The prompt to show at the REPL.
    PROMPT = "<%= color('nblog>', BOLD) %> "

    ##
    # Initializes the InteractiveShell
    # @param args [Array] Command-line arguments
    def initialize(args)
      if args.empty?
        repl
      else
        parse args * ' '
      end
    end
    
    ##
    # Simple REPL.
    def repl
      @repl_active = true
      while @repl_active
        begin
          input = ask PROMPT
          parse input
        rescue EOFError
          @repl_active = false
          puts
          exit 0
        end
      end
    end

    ##
    # Parses the input string.
    #
    # @param str [String] The input string to parse
    def parse str
      case str
      when /^help ?/i
        args = str.sub /^help ?/i, ""
        case args.strip
        when /^init$/i
          puts "Usage: init"
          puts "Initializes the database for first use."
        when /^add-user$/i
          puts "Usage: add-user [user-name [password]]"
          puts "Adds a new user.\n"
          puts "Examples:\n  * add-user nilsding"
        when /^(exit|quit)$/i
          puts "Usage: #{$1}"
          puts "#{$1.capitalize}s the management shell."
        when /^help$/i
          puts "Seriously?"
        when /.+/
          puts "Unknown command: \"#{args.strip}\""
          puts "Type \"help\" for a list of commands."
        else
          puts "Usage: help [command]"
          puts "Views help about certain commands."
          puts "Available commands:"
          puts "  - init"
          puts "  - add-user"
          puts "  - exit"
          puts "  - help\n"
          puts "Example usage:\n  help add-user"
        end
      when /^init ?/i
        print "[#{HighLine::color(' -> ', HighLine::YELLOW)}] Initializing database..."
        begin
          $db.execute_batch <<-SQL
            CREATE TABLE IF NOT EXISTS users (
              id INTEGER PRIMARY KEY,
              screen_name TEXT UNIQUE,
              password_hashed TEXT,
              can_post TEXT,
              is_admin TEXT
            );
            CREATE TABLE IF NOT EXISTS posts (
              id INTEGER PRIMARY KEY,
              content TEXT,
              created_at TEXT
            );
          SQL
          puts "\r[#{HighLine::color(' ok ', HighLine::GREEN)}]"
        rescue SQLite3::SQLException => e
          puts "\r[#{HighLine::color('fail', HighLine::RED)}]\n#{e.message}"
          puts e.backtrace.join "\n"
        end
      when /^add-user ?/i
        username = ""
        passwd = ""
        if str.match /^add-user ?(\S*)? ?(.*)?/i
          username = $1
          passwd = $2
        end
        while username.empty?
          username = ask("User name: ")
        end
        if passwd.empty?
          passwd = ask("<%= @key %>: ") do |q|
            q.echo = false
            q.verify_match = true
            q.responses[:mismatch] = "Mismatch; try again"
            q.responses[:ask_on_error] = ""
            q.gather = { "Password" => '',
                        "Retype password" => ''}
          end
        end
        print "[#{HighLine::color(' -> ', HighLine::YELLOW)}] Creating user #{username} with password \"<REDACTED>\""
        begin
          $db.execute("INSERT INTO users (screen_name, password_hashed) VALUES (?, ?);", [username, BCrypt::Password.create(passwd)])
          puts "\r[#{HighLine::color(' ok ', HighLine::GREEN)}]"
        rescue SQLite3::SQLException, SQLite3::ConstraintException => e
          case e.message
          when /^no such table/i
            e.message << " (this is usually fixed by running \"init\" first)"
          when /^unique constraint failed/i
            e.message << " (the user already exists)"
          end
          puts "\r[#{HighLine::color('fail', HighLine::RED)}]\n#{e.message}"
          puts e.backtrace.join "\n"
        end
      when /^(exit|quit) ?/i
        exit 0
      when /^#/ # comments!
      when /.+/
        puts "Unknown command: \"#{str}\""
        puts "Type \"help\" for a list of commands."
      end
    end
  end
end

# kate: indent-width 2
