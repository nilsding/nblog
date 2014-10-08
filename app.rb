#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# nblog - simple microblogging thing

require "sqlite3"
require "bcrypt"
require "sinatra"
require "haml"
require "yaml"
require "json"

# some YARD macros
# @macro [attach] sinatra.get
# @overload get "$1"
# @macro [attach] sinatra.post
# @overload post "$1"

# nblog version string
NBLOG_VERSION = "nblog 0.1.0"

# configuration
$config = YAML.load_file File.expand_path(".", "config.yml")

# SQLite3 database connection
$db = SQLite3::Database.new File.expand_path(".", $config['dbfile'])
# TODO: check if database was initialized

use Rack::Session::Pool, expire_after: 2592000
set :session_secret, $config['secret']

helpers do
  # 
  # @return +true+ or +false+, depending on whether an user is signed in
  def logged_in?
    !session[:user].nil?
  end
  # Sets or unsets the user-defined style sheet.
  # @return Path to the stylesheet
  def stylesheet
    if params[:css]
      session[:style] = params[:css].gsub(/[\\<>&"']/, "").strip()
    end
    session[:style].nil? ? "/assets/style.css" : session[:style]
  end
  # Gets a post
  # @param id [Integer] The ID of the post to get.
  # @return A dict with the keys +:id+, +:content+, +:date+ and :+url+.
  def post(id)
    row = $db.execute("SELECT id, content, created_at FROM posts WHERE id=? LIMIT 1;", [id])[0]
    {
      "id" => row[0],
      "content" => row[1],
      "date" => Time.at(row[2].to_i).strftime("%a, %d %b %Y %H:%M:%S %z"),
      "url" => "/p/#{row[0]}"
    }
  end
  # Gets the most recent posts.
  # @return An array containing dicts with the keys +:id+, +:content+, +:date+ and :+url+.
  def posts
    posts = []
    $db.execute("SELECT id, content, created_at FROM posts ORDER BY id DESC LIMIT ?;", [$config['posts_per_page']]) do |row|
      posts << {
        id: row[0],
        content: row[1],
        date: Time.at(row[2].to_i).strftime("%a, %d %b %Y %H:%M:%S %z"),
        url: "/p/#{row[0]}"
      }
    end
    posts
  end
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# @method get_index
# Gets the index page.
get "/" do
  unless session[:flash].nil?
    @message = session[:flash]
    session[:flash] = nil
  end
  @page = "index"
  haml :index
end

# @method get_post
# Gets the posts.
get "/p/:id.?:format?" do
  @p = post params[:id]
  unless params[:format].nil?
    case params[:format].downcase
    when "yml", "yaml"
      return @p.to_yaml
    when "json"
      return @p.to_json
    end
  end
  haml :post
end

# @method get_login
# Gets the login page which shows a nice login form.
get '/login' do
  unless session[:flash].nil?
    @message = session[:flash]
    session[:flash] = nil
  end
  @page = "login"
  haml :login
end

# @method post_login
# Creates a new session, if the username/password combination is correct.
post "/login" do
  $db.execute("SELECT screen_name, password_hashed FROM users WHERE lower(screen_name) = ?;", [params[:name].downcase]) do |row|
    pass = BCrypt::Password.new(row[1])
    if pass == params[:passwd]
      session[:user] = row[0]
      session[:flash] = "Successfully logged in."
      redirect(to('/'))
    end
  end
  @message = "Wrong username/password combination."
  session[:flash] = nil
  @page = "login"
  haml :login
end

# @method post_logout
# Destroys the session.
post "/logout" do
  redirect(to('/')) unless logged_in?
  session[:user] = nil
  session[:flash] = "Successfully logged out."
  redirect(to('/'))
end

# @method post_compose
# Creates a new post.
post "/compose" do
  redirect(to('/')) unless logged_in?
  unless params[:text].empty?
    $db.execute("INSERT INTO posts (content, created_at) VALUES (?, ?);", [params[:text].strip, Time.now.strftime("%s")])
    session[:flash] = "Successfully published post."
  else
    session[:flash] = "Post cannot be empty."
  end
  redirect back
end

# @method get_logout
# Returns a 403 error.
get "/logout" do
  halt 403
end

# @method get_admin
# Gets the administration panel.
get "/admin" do
  
end

# @method get_about
# Gets the about page
get "/about" do
  haml :about
end

# @method get_feed
# Gets the RSS feed.
get "/feed.xml" do
  erb :feed
end

# kate: indent-width 2