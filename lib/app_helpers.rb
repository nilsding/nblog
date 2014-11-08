module NBlog
  # module containing some helpers for NBlog
  module Helpers
    #
    # @return +true+ or +false+, depending on whether an user is signed in
    def logged_in?
      !session[:user].nil?
    end

    # Sets or unsets the user-defined style sheet.
    # @return Path to the stylesheet
    def stylesheet
      session[:style] = safe_stylesheet
      real_stylesheet
    end

    # Gets a post
    # @param id [Integer] The ID of the post to get.
    # @return [Hash] containing keys +'id'+, +'content'+, +'content_md'+,
    # +'date'+, +'url'+ and +'created_by'+.
    def post(id)
      row = NBlog.db.execute('SELECT id, content, created_at, created_by ' \
                               'FROM posts WHERE id=? LIMIT 1;', [id])[0]

      post_hash row[0], row[1], Time.at(row[2]), row[3]
    rescue NoMethodError, SQLite3::SQLException
      post_hash
    end

    # Gets the most recent posts.
    # @param page [Integer] The page to get (1-based)
    # @return An array containing dicts with the keys +:id+, +:content+,
    # +:date+ and :+url+.
    def recent_posts(page = 1)
      posts = []
      NBlog.db.execute('SELECT id FROM posts ORDER BY id DESC LIMIT ? ' \
                         'OFFSET ?;',
                       [NBlog.config['posts_per_page'],
                        NBlog.config['posts_per_page'] * (page - 1)]
      ) do |row|
        posts << post(row[0])
      end
      posts
    end

    # Groups the +posts+ per day.
    def group_per_day(posts)
      retary = {}
      posts.each do |post|
        retary[post['date'].strftime('%F')] ||= []
        retary[post['date'].strftime('%F')] << post
      end
      retary
    end

    # Returns the amount of maximum pages. (1-based)
    # @return [Integer] Page count
    def max_pages
      NBlog.db.execute('SELECT COUNT(id) / ? FROM posts;',
                       [NBlog.config['posts_per_page']])[0][0] + 1
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def strip_tags(text)
      Nokogiri::HTML(text).text
    end

    private

    def post_hash(id = -1, content = '', date = Time.at(0), created_by = 1)
      {
        'id' => id,
        'content' => $markdown.render_(content),
        'content_md' => content,
        'date' => date,
        'url' => "/p/#{id}",
        'created_by' => created_by
      }
    end

    def safe_stylesheet(css = params[:css])
      if css.nil?
        session[:style]
      else
        if css.strip.empty?
          nil
        else
          css.gsub(/[\\<>&"']/, '').strip
        end
      end
    end

    def real_stylesheet(style = session[:style])
      if style.nil?
        NBlog.config['default_stylesheet']
      else
        style
      end
    end
  end
end
