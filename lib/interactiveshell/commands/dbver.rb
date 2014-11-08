require_relative '../base'

command = InteractiveShellCommand.new

command.create :dbver do
  related_commands :update

  main do
    line 'Database version ', newline: false
    line NBlog.db.execute(
         'SELECT value FROM db_info WHERE key=? LIMIT 1;', ['version'])[0][0]
  end

  help_text do
    line 'Prints the current database schema version.'
  end
end
