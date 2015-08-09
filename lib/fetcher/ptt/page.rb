module Fetcher
  class PTT
    # 以頁面為基礎的爬蟲
    # 你可以傳入網址建立物件
    # => Fetcher::PTT::Page.new('bbs/Gossiping/index7950.html')
    #
    # 使用 fetch 來進行抓取
    # => Fetcher::PTT::Page.new('bbs/Gossiping/index7950.html').fetch
    #
    # 以上兩步驟可合併為 shortcut
    # => Fetcher::PTT::Page.fetch('bbs/Gossiping/index7950.html')
    class Page
      Paging = Struct.new(:prev_url, :next_url)
      PAGE_URL_PATTERN = %r{bbs/Gossiping/index(?<page_id>\d+)\.html\Z}

      attr_reader :url, :raw_data, :articles, :paging

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
        return @next_page if @next_page
        return nil if paging.next_url.nil?

        @next_page ||= Page.new(paging.next_url)
      end

      def prev
        return @prev_page if @prev_page
        return nil if paging.prev_url.nil?

        @prev_page ||= Page.new(paging.prev_url)
      end

      private

      def client
        @client ||= Client.new
      end

      def parse_info
        @articles = parse_meta_articles
        @paging = parse_paging

        # Page's url will be 'bbs/Gossiping/index.html' when passin newest url.
        # That will cause inconsistent with other page. We should correct it by prev page url.
        @url = current_url_by_prev_page_url if url_is_newest?
      end

      def parse_meta_articles
        @articles =
          doc.css('.r-ent').map do |meta_article_raw_data|
            Article.new(meta_article_raw_data)
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

      # bbs/Gossiping/index.html => true
      # bbs/Gossiping/index10789.html => false
      def url_is_newest?
        !url.match(PAGE_URL_PATTERN)
      end

      def current_url_by_prev_page_url
        page_id = paging.prev_url.match(PAGE_URL_PATTERN)[:page_id]
        "bbs/Gossiping/index#{page_id}.html"
      end
    end
  end
end
