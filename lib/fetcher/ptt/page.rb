module Fetcher
  class PTT
    class Page
      Paging = Struct.new(:prev_url, :next_url)

      attr_reader :url, :raw_data, :meta_articles, :paging

      def self.fetch(*args)
        new(*args).fetch
      end

      def initialize(url)
        @url = url
      end

      def fetch
        resp = client.get(url)
        @raw_data = resp.body

        parse_info

        self
      end

      def next
        return nil if paging.next_url.nil?

        Page.new(paging.next_url)
      end

      def prev
        return nil if paging.prev_url.nil?

        Page.new(paging.prev_url)
      end

      private

      def client
        @client ||= Client.new
      end

      def parse_info
        @meta_articles = parse_meta_articles
        @paging = parse_paging
      end

      def parse_meta_articles
        @meta_articles =
          doc.css('.r-ent').map do |meta_article_raw_data|
            MetaArticle.new(meta_article_raw_data)
          end
      end

      def parse_paging
        paging_elem = doc.css('.action-bar a.btn.wide')
        next_url = paging_elem.find { |s| s.text == '下頁 ›' }.attributes['href'].try(:value)
        prev_url = paging_elem.find { |s| s.text == '‹ 上頁' }.attributes['href'].try(:value)

        Paging.new(prev_url, next_url)
      end

      def doc
        @doc ||= Nokogiri::HTML(raw_data)
      end
    end
  end
end
