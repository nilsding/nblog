# Yet another self-hosted microblogging thing!

[![build status](https://ci.rrerr.net/projects/2/status.png?ref=master)](https://ci.rrerr.net/projects/2?ref=master)

**nblog** is a self-hosted microblogging software written in Ruby using Sinatra
and SQLite3.

## Features

* Easy to use
* RSS-Feed of the posts
* Posts can be written in Markdown
* Include external CSS files (append `?css=http://path/to/stylesheet.css` to
the URL to apply)

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

* Pagination
* Streaming API (maybe?)
* add ability to subscribe to friends via RSS feeds
* Database migration