module Fetcher
  class PTT
    class MetaArticle
      attr_reader :doc,
                  :push_number,
                  :date,
                  :author,
                  :link,
                  :raw_title,
                  :title,
                  :tag,
                  :is_re,
                  :is_deleted,
                  :article

      def initialize(doc)
        @doc = doc
        parse_info_and_assign
      end

      private

      def parse_info_and_assign
        @push_number = parse_push_number
        @date        = parse_date
        @author      = parse_author
        @link        = parse_link
        @is_deleted  = @link ? false : true

        @raw_title = parse_raw_title

        title_info = parse_title
        @title     = title_info[:title]
        @is_re     = title_info[:is_re]
        @tag       = title_info[:tag]
      end

      def parse_push_number
        doc.css('.nrec').text.to_i
      end

      def parse_date
        doc.css('.date').text.strip
      end

      def parse_author
        doc.css('.author').text.strip
      end

      def parse_link
        a_tag = doc.css('.title a').first
        a_tag ? a_tag.attributes["href"].value : nil
      end

      def parse_raw_title
        doc.css('.title').text.strip
      end

      def parse_title
        text = raw_title.dup

        is_re = text.slice!(/^Re:/) ? true : false
        # 如果該篇文章被刪除，則會找不到 tag，所以使用 try
        tag   = text.slice!(/\[(.*)\]/).try(:slice, /\[(.*)\]/, 1)
        title = text.strip

        { is_re: is_re, title: title, tag: tag }
      end
    end
  end
end
