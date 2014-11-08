require_relative '../base'

require 'highline/import'
require 'bcrypt'

command = InteractiveShellCommand.new

command.create :"add-user" do
  argument :username, :optional
  argument :password, :optional

  related_commands :"edit-user", :"del-user"

  main do
    username = ''
    password = ''
    res = @args_str.match(/^(\S*)? ?(.*)?/i)
    if res
      username = res[1]
      password = res[2]
    end
    username = ask('User name: ') while username.empty?
    if password.empty?
      password = ask('<%= @key %>: ') do |q|
        q.echo = false
        q.verify_match = true
        q.responses[:mismatch] = 'Mismatch; try again'
        q.responses[:ask_on_error] = ''
        q.gather = { :'Password' => '',
                     :'Retype password' => '' }
      end
    end
    sql "Creating user #{username}",
        'INSERT INTO users ' \
        '(screen_name, password_hashed, can_post, is_admin) ' \
        'VALUES (?, ?, ?, ?);',
        [username, BCrypt::Password.create(password), 't', 't']
  end

  help_text do
    line 'Adds a new user.'
  end
end
