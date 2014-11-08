require 'redcarpet'

module NBlog
  # Provides a Redcarpet markdown renderer
  class MarkdownRenderer
    # Renders +md+ without the first <p> tag.
    # @param md [String] The markdown to render
    def self.render(md)
      result = @markdown.render(md)
      2.times { result.sub!(/<\/?p>/, '') }
      result
    end

    # Redcarpet HTML renderer for NBlog.
    class NBlogRenderer < Redcarpet::Render::HTML
      def header(text, _header_level)
        "<p>#{text}</p>"
      end

      def raw_html(raw_html)
        Rack::Utils.escape_html raw_html
      end
    end

    @markdown = Redcarpet::Markdown.new(NBlogRenderer,
                                        no_intra_emphasis: true,
                                        fenced_code_blocks: true,
                                        strikethrough: true,
                                        autolink: true,
                                        filter_html: true,
                                        tables: true)
  end
end
