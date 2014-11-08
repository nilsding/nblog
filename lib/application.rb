#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# nblog - simple microblogging thing

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'configuration'
require 'bcrypt'
require 'sinatra/base'
require 'haml'
require 'yaml'
require 'json'
require 'nokogiri'

require 'app_helpers'
require 'post_controller'

# nblog main module.
module NBlog
  # nblog Sinatra application.
  class Application < Sinatra::Base
    use Rack::Session::Pool, expire_after: 2592000
    set :app_file, File.expand_path('../', __FILE__)
    set :session_secret, NBlog.config['secret']
    set :bind, NBlog.config['hostname']
    set :port, NBlog.config['port']

    not_found do
      haml :error_404
    end

    helpers NBlog::Helpers

    use NBlog::PostController

    # some YARD macros
    # @macro [attach] sinatra.get
    # @overload get "$1"
    # @macro [attach] sinatra.post
    # @overload post "$1"

    # @method get_index
    # Gets the index page.
    get '/' do
      unless session[:flash].nil?
        @message = session[:flash]
        session[:flash] = nil
      end
      @page = 'index'
      @current_page = 1
      haml :index
    end

    # @method get_posts_page
    # Gets the posts for page +:page+.
    get '/!:page' do
      unless session[:flash].nil?
        @message = session[:flash]
        session[:flash] = nil
      end
      @page = 'index'
      @current_page = params[:page].to_i
      haml :index
    end

    # @method get_login
    # Gets the login page which shows a nice login form.
    get '/login' do
      unless session[:flash].nil?
        @message = session[:flash]
        session[:flash] = nil
      end
      @page = 'login'
      haml :login
    end

    # @method post_login
    # Creates a new session, if the username/password combination is correct.
    post '/login' do
      NBlog.db.execute('SELECT id, screen_name, password_hashed FROM users ' \
                       'WHERE lower(screen_name) = ?;',
                       [params[:name].downcase]) do |row|
        pass = BCrypt::Password.new(row[2])
        if pass == params[:passwd]
          session[:user] = { id: row[0], screen_name: row[1] }
          session[:flash] = 'Successfully logged in.'
          redirect(to('/'))
        end
      end
      @message = 'Wrong username/password combination.'
      session[:flash] = nil
      @page = 'login'
      haml :login
    end

    # @method post_logout
    # Destroys the session.
    post '/logout' do
      redirect(to('/')) unless logged_in?
      session[:user] = nil
      session[:flash] = 'Successfully logged out.'
      redirect(to('/'))
    end

    # @method post_compose
    # Creates a new post.
    post '/compose' do
      redirect(to('/')) unless logged_in?
      if params[:text].strip.empty?
        session[:flash] = 'Post cannot be empty.'
      else
        NBlog.db.execute('INSERT INTO posts (content, created_at, created_by)'\
                         'VALUES (?, ?, ?);',
                         [params[:text].strip, Time.now.strftime('%s'),
                          session[:user][:id]])
        session[:flash] = 'Successfully published post.'
      end
      redirect back
    end

    # @method get_logout
    # Returns a 403 error.
    get '/logout' do
      halt 403
    end

    # @method get_admin
    # Gets the administration panel.
    get '/admin' do
      haml :error_404
    end

    # @method get_about
    # Gets the about page
    get '/about' do
      haml :about
    end

    # @method get_feed
    # Gets the RSS feed.
    get '/feed.xml' do
      erb :feed
    end
  end
end

# kate: indent-width 2
