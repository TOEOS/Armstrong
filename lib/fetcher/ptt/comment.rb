module Fetcher
  class PTT
    # Article 的附屬物件，只負責 parse comment 的 Nokogiri Element，
    # 以及 Comment 相關的操作
    class Comment
      COMMENT_TYPE_TEXT_PATTERN = {
        push: /推/,
        boo: /噓/,
        neutral: /→/
      }.freeze

      attr_reader :doc,
                  :comment_type,
                  :commenter,
                  :content,
                  :date,
                  :article

      def initialize(comment_doc, article)
        @article = article
        @doc = comment_doc

        parse_info_and_assign

        self
      end

      def to_h
        {
          comment_type: comment_type,
          commenter: commenter,
          content: content,
          date: date,
          article: {
            url_id: article.url_id,
            url: article.url
          }
        }
      end

      private

      def parse_info_and_assign
        @comment_type = parse_comment_type
        @commenter = parse_commenter
        @date = parse_date
        @content = parse_content
      end

      def parse_comment_type
        doc.css('.push-tag').text.strip
      end

      def parse_commenter
        doc.css('.push-userid').text.strip
      end

      def parse_date
        Time.zone.parse(doc.css('.push-ipdatetime').text)
      end

      def parse_content
        # 原始的文字會是 ": 當世界只剩下你們三個人時,你會跟誰在一起"
        # 去掉開頭的部分 ": "
        doc.css('.push-content').text.gsub(/^(:\s{1})/, '')
      end
    end
  end
end
