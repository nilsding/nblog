require_relative '../base'

command = InteractiveShellCommand.new

command.create :init do
  related_commands :update

  main do
    sql_batch 'Initializing database', '
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
      INSERT INTO db_info (key, value) VALUES ("version", "0");
    ', []
  end

  help_text do
    line 'Initializes the database for first use.'
    line 'This will reset the database!  ', style: :danger, newline: false
    line 'All your posts will be deleted and the users have to be ' \
         'recreated again.  To update the database schema, take a look at'
    line 'update', style: :underline, newline: false
    line '.'
  end
end
