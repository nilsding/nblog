require 'highline/import'
require 'configuration'

module NBlog
  # Class to provide an interactive management shell.
  class InteractiveShell
    # The prompt to show at the REPL.
    PROMPT = "<%= color('nblog>', BOLD) %> "

    ##
    # Initializes the InteractiveShell
    # @param args [Array] Command-line arguments
    # @param run_repl [Boolean] Start the REPL if no command line arguments are
    # given
    def initialize(args, run_repl = true)
      load_commands
      if args.empty? && run_repl
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
      read_and_parse while @repl_active
    end

    ##
    # Parses the input string.
    #
    # @param str [String] The input string to parse
    def parse(str)
      res = str.match(/^(\S+)\s?(.*)$/)
      return unless res
      cmd = res[1].strip.to_sym
      args = res[2].strip
      IS_CMDS[cmd].execute(args) if IS_CMDS.include? cmd
    end

    private

    def load_commands
      NBlog.config['interactive_shell_commands'].each do |cmd|
        begin
          require "interactiveshell/commands/#{cmd}"
        rescue => e
          puts "Failed to load command #{cmd}: #{e.message}"
        end
      end
    end

    def read_and_parse
      input = ask PROMPT
      parse input
    rescue EOFError
      @repl_active = false
      puts
      exit 0
    end
  end
end

# kate: indent-width 2
