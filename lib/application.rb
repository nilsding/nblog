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
require 'redcarpet'
require 'nokogiri'

require 'app_helpers'

# nblog main module.
module NBlog
  # Redcarpet HTML renderer for NBlog.
  class NBlogRenderer < Redcarpet::Render::HTML
    def header(text, _header_level)
      "<p>#{text}</p>"
    end

    def raw_html(raw_html)
      Rack::Utils.escape_html raw_html
    end
  end

  $markdown = Redcarpet::Markdown.new(NBlogRenderer,
                                      no_intra_emphasis: true,
                                      fenced_code_blocks: true,
                                      strikethrough: true,
                                      autolink: true,
                                      filter_html: true,
                                      tables: true)

  # Renders the page without the first <p> tag.
  def $markdown.render_(md)
    retstr = render(md)
    2.times { retstr.sub!(/<\/?p>/, '') }
    retstr
  end

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

    helpers do
      include NBlog::Helpers
    end

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

    # @method get_post
    # Gets a post.
    get '/p/:id.?:format?' do
      @p = post params[:id]
      halt 404 if @p['id'] == -1
      unless params[:format].nil?
        case params[:format].downcase
        when 'yml', 'yaml'
          return @p.to_yaml
        when 'json'
          return @p.to_json
        end
      end
      haml :post
    end

    # @method get_post_edit
    # Edits a post.
    get '/p/:id/edit' do
      redirect(to('/')) unless logged_in?
      unless session[:flash].nil?
        @message = session[:flash]
        session[:flash] = nil
      end
      @p = post params[:id]
      haml :edit
    end

    post '/update' do
      redirect(to('/')) unless logged_in?
      if params[:text].strip.empty? || params[:post_id].empty?
        session[:flash] = 'Post cannot be empty.'
      else
        NBlog.db.execute('UPDATE posts SET content=? WHERE id=?;',
                         [params[:text].strip, params[:post_id]])
        session[:flash] = 'Successfully updated post.'
      end
      redirect back
    end

    post '/delete' do
      redirect(to('/')) unless logged_in?
      unless params[:post_id].empty?
        NBlog.db.execute('DELETE FROM posts WHERE id=?;', [params[:post_id]])
        session[:flash] = 'Successfully deleted post.'
      end
      redirect '/'
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
