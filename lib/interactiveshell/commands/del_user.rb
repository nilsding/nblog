require_relative '../base'

require 'highline/import'

command = InteractiveShellCommand.new

command.create :"del-user" do
  argument :username, :optional

  related_commands :"add-user", :"edit-user"

  main do
    username = ''
    res = @args_str.match(/^(\S*)?/i)
    username = res[1] if res
    username = ask('User name: ') while username.empty?
    # TODO: ask if the user should be really deleted
    sql "Deleting user #{username}",
        'DELETE FROM users WHERE screen_name=?;', [username]
  end

  help_text do
    line 'Deletes an user.'
  end
end
