require_relative '../base'

command = InteractiveShellCommand.new

command.create :help do
  argument :command, :optional

  main do
    cmd_name = @args_str.to_sym
    if IS_CMDS.include? cmd_name
      IS_CMDS[cmd_name].help
    else
      unless @args_str.empty?
        puts "\"#{cmd_name}\" is an unknown command to me :(\n"
      end
      line 'Available commands:'
      IS_CMDS.each do |_k, cmd|
        line "  - #{cmd.name}"
      end
    end
  end

  help_text do
    line 'Seriously?'
  end
end
