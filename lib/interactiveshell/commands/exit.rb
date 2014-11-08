require_relative '../base'

command = InteractiveShellCommand.new

command.create :exit do
  main do
    exit 0
  end

  help_text do
    line 'Exits the management shell.'
  end
end
