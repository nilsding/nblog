# Yet another self-hosted microblogging thing!

**nblog** is a self-hosted (single-user) microblogging software written in Ruby
using Sinatra and SQLite3.

## Features

* Easy to use
* RSS-Feed of the posts
* Include external CSS files

## Requirements

* A UNIX system (Linux, *BSD, ...)
* Ruby 1.9.3+
* Bundler (`gem install bundler`)

## Installation

### Production

1. Install the dependencies: `bundle install --without test development`
2. Initialize the database: `ruby manage.rb init`
3. Create a new user: `ruby manage.rb add-user _username_`.  You will be
prompted to enter a password.
4. Run the application, either with `RACK_ENV=production ./app.rb` or with
`unicorn -p PORT -e production`, depending on what you prefer.
5. Configure your webserver (take a look at the `misc/` directory for some
example configurations)

### Development

1. Install the dependencies: `bundle install`
2. Initialize the database: `ruby manage.rb init`
3. Create a new user: `ruby manage.rb add-user _username_`.  You will be
prompted to enter a password.
4. Run the application: `shotgun`

## Personal TODO list

* Write more tests
* Pagination
* grouping by month
* Streaming API (maybe?)
* add ability to subscribe to friends via RSS feeds
