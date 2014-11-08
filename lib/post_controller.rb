require 'sinatra/base'

module NBlog
  # class containing methods for GET and POST
  class PostController < Sinatra::Base
    use Rack::Session::Pool, expire_after: 2592000
    set :app_file, File.expand_path('../', __FILE__)
    set :session_secret, NBlog.config['secret']

    not_found do
      haml :error_404
    end

    helpers do
      include NBlog::Helpers
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
    # Shows an edit view for a post.
    get '/p/:id/edit' do
      redirect(to('/')) unless logged_in?
      unless session[:flash].nil?
        @message = session[:flash]
        session[:flash] = nil
      end
      @p = post params[:id]
      haml :edit
    end

    # @method post_post_update
    # Updates a post.
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

    # @method post_post_delete
    # Deletes a post.
    post '/delete' do
      redirect(to('/')) unless logged_in?
      unless params[:post_id].empty?
        NBlog.db.execute('DELETE FROM posts WHERE id=?;', [params[:post_id]])
        session[:flash] = 'Successfully deleted post.'
      end
      redirect '/'
    end
  end
end
