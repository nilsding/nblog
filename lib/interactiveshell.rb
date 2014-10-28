require "highline/import"
require "bcrypt"
require "configuration"

module NBlog
  # Class to provide an interactive management shell.
  class InteractiveShell
    # The prompt to show at the REPL.
    PROMPT = "<%= color('nblog>', BOLD) %> "
    
    ##
    # Initializes the InteractiveShell
    # @param args [Array] Command-line arguments
    # @param run_repl [Boolean] Start the REPL if no command line arguments are given
    def initialize(args, run_repl=true)
      if args.empty? and run_repl
        repl
      else
        parse args * ' '
      end
    end
    
    ##
    # Simple REPL.
    def repl
      trap 'INT' do
        puts
        exit 0
      end
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
          print "#{HighLine::color("This will reset the database!", HighLine::RED, HighLine::BOLD)}  "
          puts "All your posts will be deleted, and the users"
          puts "have to be recreated again.  To upgrade the database schema, take a look at"
          puts "#{HighLine::color("update", HighLine::UNDERLINE)}."
          puts "\n#{related_cmds %w(update)}"
        when /^update|upgrade$/i
          puts "Usage: update"
          puts "Updates the database to a newer version."
          puts "If you just initialized the database, it should be already the recent"
          puts "version."
          puts "\n#{related_cmds %w(init dbver)}"
        when /^dbver$/
          puts "Usage: dbver"
          puts "Prints the current database schema version."
          puts "\n#{related_cmds %w(update)}"
        when /^add-user$/i
          puts "Usage: add-user [user-name [password]]"
          puts "Adds a new user.\n"
          puts "Examples:\n  * add-user nilsding"
          puts "\n#{related_cmds %w(edit-user del-user)}"
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
          puts "  - update"
          puts "  - dbver"
          puts "  - add-user"
          puts "  - edit-user"
          puts "  - del-user"
          puts "  - exit"
          puts "  - help\n"
          puts "Example usage:\n  help add-user"
        end
      when /^init ?/i
        run_sql("
          DROP TABLE IF EXISTS db_info;
          DROP TABLE IF EXISTS users;
          DROP TABLE IF EXISTS posts;
          CREATE TABLE db_info (
            key VARCHAR(20) PRIMARY KEY,
            value TEXT
          );
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            screen_name TEXT UNIQUE,
            password_hashed TEXT,
            can_post TEXT,
            is_admin TEXT
          );
          CREATE TABLE posts (
            id INTEGER PRIMARY KEY,
            content TEXT,
            created_by INTEGER,
            created_at NUMERIC
          );
          INSERT INTO db_info (key, value) VALUES (\"version\", \"0\");
        ", [], "Initializing database", true)
      when /^dbver ?/i
        puts "Database version " + NBlog.db.execute("SELECT value FROM db_info WHERE key=? LIMIT 1;", ["version"])[0][0]
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
        run_sql("INSERT INTO users (screen_name, password_hashed, can_post, is_admin) VALUES (?, ?, ?, ?);", [username, BCrypt::Password.create(passwd), 't', 't'],
                "Creating user #{username}")
      when /^del-user ?/i
        username = ""
        username = $1 if str.match /^del-user ?(\S*)?/i
        username = ask("User name: ") while username.empty?
        # TODO: ask if the user should be really deleted
        run_sql("DELETE FROM users WHERE screen_name=?;", [username],
                "Deleting user #{username}")
      when /^(edit-user|update) ?/i
        puts "This method is not implemented yet."
      when /^(exit|quit) ?/i
        exit 0
      when /^#/ # comments!
      when /.+/
        puts "Unknown command: \"#{str}\""
        puts "Type \"help\" for a list of commands."
      end
    end
    
    private
      # Returns a string containing the related commands.
      # @param cmdlist [Array] The related commands.
      def related_cmds(cmdlist)
        "Related commands: #{cmdlist.map { |cmd| HighLine::color(cmd, HighLine::UNDERLINE) } * ' ' }"
      end
      
      # Executes the given SQL statement, printing out a message to the console.
      # @param sql [String] The SQL statement to use.
      # @param bind_vars [Array] 
      # @param message [String] The message to print.
      # @param batch [Boolean] Use SQLite3's +execute_batch+ method.
      def run_sql(sql, bind_vars=[], message="SQL", batch=false)
        print "[#{HighLine::color(' -> ', HighLine::YELLOW)}] #{message}"
        begin
          if batch
            NBlog.db.execute_batch(sql, bind_vars)
          else
            NBlog.db.execute(sql, bind_vars)
          end
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
      end
  end
end

# kate: indent-width 2
