module Fetcher
  class PTT
    class Article
      META_TAG_TEXT_IN_PAGE = {
        title: '標題',
        author: '作者',
        date: '時間'
      }.freeze

      attr_reader :meta_article,
                  :url,
                  :raw_data,
                  :raw_title,
                  :title,
                  :is_re,
                  :title_tag,
                  :author,
                  :date,
                  :raw_content,
                  :content,
                  :signature_line,
                  :author_ip

      def initialize(*args)
        @is_fetched = false

        if args[0].is_a?(String)
          @url = args[0]
        elsif args[0].is_a?(Nokogiri::XML::Element)
          @meta_article = MetaArticle.new(args[0])
          @url = @meta_article.link
        end
      end

      def fetch
        resp = client.get(url)
        @raw_data = resp.body

        parse_article_and_assign

        @is_fetched = true

        self
      end

      def fetched?
        @is_fetched
      end

      def to_h
        {
          meta_article: meta_article.as_json,
          url: url,
          title: title,
          is_re: is_re,
          title_tag: title_tag,
          author: author,
          date: date,
          content: content,
          signature_line: signature_line,
          author_ip: author_ip
        }
      end

      private

      def client
        @client ||= Client.new
      end

      def doc
        @doc ||= Nokogiri::HTML(raw_data)
      end

      def parse_article_and_assign
        @raw_title = parse_raw_title

        title_info = parse_title
        @title     = title_info[:title]
        @is_re     = title_info[:is_re]
        @title_tag       = title_info[:title_tag]

        @author = parse_author
        @date = parse_date

        @raw_content = parse_raw_content
        content_info = parse_content

        @content = content_info[:content]
        @signature_line = content_info[:signature_line]
        @author_ip = content_info[:author_ip]
      end

      def parse_raw_title
        get_meta_line_of(META_TAG_TEXT_IN_PAGE[:title])
      end

      def parse_title
        text = raw_title.dup

        is_re = text.slice!(/^Re:/) ? true : false
        title_tag   = text.slice!(/\[(.*)\]/).try(:slice, /\[(.*)\]/, 1)
        title = text.strip

        { is_re: is_re, title: title, title_tag: title_tag }
      end

      def parse_author
        get_meta_line_of(META_TAG_TEXT_IN_PAGE[:author]).strip
      end

      def parse_date
        raw_date = get_meta_line_of(META_TAG_TEXT_IN_PAGE[:date])
        Time.zone.parse(raw_date)
      end

      def get_meta_line_of(value)
        @_meta_line_elems ||= doc.css('.article-metaline')
        line_elem = @_meta_line_elems.find do |elem|
          elem.css('.article-meta-tag').text =~ Regexp.new(value)
        end

        line_elem ? line_elem.css('.article-meta-value').text : nil
      end

      def parse_raw_content
        content_elem = doc.css('#main-content').dup

        content_elem.css('.article-metaline').remove
        content_elem.css('.article-metaline-right').remove
        content_elem.css('.push').remove
        content_elem.text
      end

      def parse_content
        content_text = raw_content.dup

        line_after_personal_quate = content_text.slice!(/※ 發信站: 批踢踢實業坊\(ptt.cc\), 來自:.*/m)
        author_ip =
          line_after_personal_quate
          .match(/來自:.*(?<author_ip>(?:[0-9]{1,3}\.){3}[0-9]{1,3}).*※ 文章網址/m)[:author_ip]

        # 有可能沒有簽名檔
        signature_line = content_text.slice!(/--(?<signature_line>.*)--\Z/m, :signature_line).try(:strip)

        content = content_text.lstrip

        { content: content, signature_line: signature_line, author_ip: author_ip }
      end
    end
  end
end
