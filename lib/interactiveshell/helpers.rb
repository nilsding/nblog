require 'highline/import'
require_relative '../configuration'

module NBlog
  class InteractiveShell
    # Class containing several helpers for the Interactive Shell
    class Helpers
      # Returns the usage of the command +cmd+ with args +args+.
      # @param cmd [Symbol] Name of the command
      # @param args [Hash] Hash containing the keys :required and :optional
      # @return [String] The usage string
      def self.usage(cmd, args)
        arg_str = "Usage: #{cmd} "
        args[:required].each { |arg| arg_str << "#{arg} "  }
        args[:optional].each { |arg| arg_str << "[#{arg} " }
        arg_str.strip!
        args[:optional].length.times { arg_str << ']' }
        arg_str
      end

      # Returns related commands.
      # @param cmdlist [Array] The related commands.
      # @return [String] The related commands as string
      def self.related_cmds(cmdlist)
        "Related commands: #{cmdlist.map do |cmd|
          HighLine.color(cmd.to_s, HighLine::UNDERLINE)
        end } * ' ' }"
      end

      # Executes the given SQL statement, printing out a message to the console.
      # @param message [String] The message to print.
      # @param sql [String] The SQL statement to use.
      # @param bind_vars [Array]
      # @param batch [Boolean] Use SQLite3's +execute_batch+ method.
      def self.run_sql(message, sql, bind_vars = [], batch = false)
        print "[#{HighLine.color(' -> ', HighLine::YELLOW)}] #{message}"
        begin
          execute(batch, sql, bind_vars)
          puts "\r[#{HighLine.color(' ok ', HighLine::GREEN)}]"
        rescue SQLite3::SQLException, SQLite3::ConstraintException => e
          append_to_message(e.message)
          puts "\r[#{HighLine.color('fail', HighLine::RED)}]\n#{e.message}"
          puts e.backtrace.join "\n"
        end
      end

      private

      def self.execute(batch, sql, bind_vars)
        if batch
          NBlog.db.execute_batch(sql, bind_vars)
        else
          NBlog.db.execute(sql, bind_vars)
        end
      end

      def self.append_to_message(message)
        case message
        when /^no such table/i
          message << ' (this is usually fixed by running "init" first)'
        when /^unique constraint failed/i
          message << ' (the user already exists)'
        end
      end
    end
  end
end
