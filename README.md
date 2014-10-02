# Yet another self-hosted microblogging thing!

**nblog** is a self-hosted single-user microblogging software written in Ruby
using Sinatra and SQLite3.

## Features

* Simple to use
* RSS-Feed of the posts
* Include external CSS files

## Requirements

* A UNIX system (Linux, *BSD, ...)
* Ruby 1.9.3+
* Bundler (`gem install bundler`)

## Installation

1. Install the dependencies: `bundle install`
2. Initialize the database: `ruby manage.rb init`
3. Create a new user: `ruby manage.rb add-user _username_`.  You will be
prompted to enter a password.
4. Run the application: `./app.rb -p _port_ -e production`
5. Configure your webserver (take a look at the `misc/` directory for some
example configurations)

## Personal TODO list

* Write more tests
* Pagination
* Streaming API (maybe?)