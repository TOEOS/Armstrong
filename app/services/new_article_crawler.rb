# How to Use
#
# 1. crawl all new articles
#
#      NewArticleCrawler.call
#
#      or
#
#      NewArticleCrawler.new.call
#
# 2. crawl all new articles in n batch
#
#      new_article_crawlers = NewArticleCrawler.spawn(4)
#      #=> [#<NewArticleCrawler>, #<NewArticleCrawler>, #<NewArticleCrawler>, #<NewArticleCrawler>]
#
#      new_article_crawlers.each(&:call)
#      #=> crawlers will crawl each by each
#

class NewArticleCrawler
  extend DebugConfigs

  attr_reader :links

  class << self
    def call
      new.call
    end

    def spawn(number)
      new.split(number)
    end

    def spawn_json(number)
      spawn(number).map {|crawler| crawler.links.to_json }
    end
  end

  def initialize(links = nil)
    @links = links || []
    @configs = {
      page_number: 10400,
      find_newest_article_date_page: false,
      find_newest_article_page: false
    }
    @events = Event.all
  end

  def split(number)
    if !@called
      newest_three_articles = Article.select(:title, :post_at).order(post_at: :desc).limit(3)

      last_article_date = newest_three_articles.first.try(:post_date) || Date.today.strftime("%_m/%d")

      newest_three_article_titles = newest_three_articles.map(&:title)

      find_newest_article_date_page(last_article_date)

      find_newest_article_page(newest_three_article_titles, for_spwan: true) if newest_three_articles.any?

      crawl_new_articles(for_spwan: true)

      @links.each_slice(@links.length / number + 1).map {|group_of_links| self.class.new(group_of_links) }
    end
  end

  def call
    debugging_start_time = Time.now

    if @links != []
      @links.each {|link| crawl_artcile(link)}

      @called = true
    else
      newest_three_articles = Article.select(:title, :post_at).order(post_at: :desc).limit(3)

      last_article_date = newest_three_articles.first.try(:post_date) || Date.today.strftime("%_m/%d")

      newest_three_article_titles = newest_three_articles.map(&:title)

      find_newest_article_date_page(last_article_date)

      debugging_find_newest_article_date_page_time = Time.now

      find_newest_article_page(newest_three_article_titles) if newest_three_articles.any?

      debugging_find_newest_article_page = Time.now

      self.class.debug("start crawl_new_articles")

      crawl_new_articles

      @called = true
    end

    self.class.debug("start crawler at: #{debugging_start_time}")
    self.class.debug("find_newest_article_date_page at: #{debugging_find_newest_article_date_page_time}") if @links == []
    self.class.debug("find_newest_article_page at: #{debugging_find_newest_article_page}") if @links == []
    self.class.debug("end crawler at: #{Time.now}")
  end

  def find_newest_article_date_page(last_article_date)
    self.class.debug('start find_newest_article_date_page')
    while !@configs[:find_newest_article_date_page]
      self.class.debug("page: #{@configs[:page_number]}")
      ptt_url = "https://www.ptt.cc/bbs/Gossiping/index#{@configs[:page_number]}.html"

      begin
        doc = Nokogiri::HTML(open(ptt_url, 'Cookie'=> 'over18=1'))
      rescue
        next
      end

      article_days = doc.css('.r-ent').css('.meta').css('.date').map(&:text).uniq

      article_days.include?(last_article_date) ?
        @configs[:find_newest_article_date_page] = true :
        @configs[:page_number] += 1
    end
    self.class.debug("\n")
  end

  def find_newest_article_page(newest_three_article_titles, for_spwan: false)
    self.class.debug('start find_newest_article_page')
    while !@configs[:find_newest_article_page]
      self.class.debug("page: #{@configs[:page_number]}")
      ptt_url = "https://www.ptt.cc/bbs/Gossiping/index#{@configs[:page_number]}.html"

      begin
        doc = Nokogiri::HTML(open(ptt_url, 'Cookie'=> 'over18=1'))
      rescue
        @configs[:page_number] -= 1
        break
      end

      article_titles = doc.css('.r-ent').css('.title').xpath('a').map(&:text)

      newest_article_index = newest_three_article_titles.map {|t| article_titles.index(t) }.compact.first

      if newest_article_index
        new_articles_links = doc.css('.r-ent').css('.title').xpath('a')[newest_article_index..-1].
                               select {|a_tag| a_tag.text.match(/新聞|爆[卦掛]/)}.
                               map {|a_tag| a_tag[:href]}

        if for_spwan
          return @links.push(*new_articles_links)
        end

        new_articles_links.each do |link|
          crawl_artcile(link)
        end

        @configs[:find_newest_article_page] = true
        @configs[:page_number] += 1
      else
        @configs[:page_number] += 1
      end
    end
    self.class.debug("\n")
  end

  def crawl_new_articles(for_spwan: false)
    self.class.debug("page: #{@configs[:page_number]}")
    while true
      ptt_url = "https://www.ptt.cc/bbs/Gossiping/index#{@configs[:page_number]}.html"

      begin
        doc = Nokogiri::HTML(open(ptt_url, 'Cookie'=> 'over18=1'))
      rescue
        @configs[:page_number] -= 1
        return @links if for_spwan
        break
      end

      new_articles_links = doc.css('.r-ent').css('.title').xpath('a').
                               select {|a_tag| a_tag.text.match(/新聞|爆[卦掛]/)}.
                               map {|a_tag| a_tag[:href]}

      if for_spwan
        @links.push(*new_articles_links)
      else
        new_articles_links.each do |link|
          crawl_artcile(link)
        end
      end

      @configs[:page_number] += 1
    end
  end

  def crawl_artcile(link, crawl_comments: true)
    get_article = false

    while !get_article
      begin
        doc = Nokogiri::HTML(open('https://www.ptt.cc/'+link, 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')
        get_article = true if doc
      rescue
        next
      end
    end

    if doc.css('.article-metaline').length == 3
      article = Article.create(article_params(doc, 'https://www.ptt.cc/'+link))

      if crawl_comments
        article_id = article.id

        comments = doc.css('.push')

        comments.each {|c| Comment.create(article_id: article_id, **comment_params(c)) }
      end

      if article.event_id
        client = Apollo.create(article.event_id)
        client.push(article, 'article')
        client.push(article, 'article_comment')
      end
    end
  end

  private

  def article_params(doc, link)
    arthor = doc.css('.article-metaline')[0].css('.article-meta-value').text

    title = doc.css('.article-metaline')[1].css('.article-meta-value').text

    post_at = Time.parse(doc.css('.article-metaline')[2].css('.article-meta-value').text)

    doc.css('.article-metaline, .article-metaline-right').remove

    content = doc.text.split("--\n※ 發信站: 批踢踢實業坊(ptt.cc)").first

    comments_count = doc.css('.push').length

    keywords = JiebaService.new.keywords(content)

    event_id = EventMatchService.best_match_event(@events, keywords).try(:id)

    pic_links = content.scan(/https?:\/\/[a-zA-Z0-9_\/.?=&]+/)
                  .select do |link|
                    open(link) { |f| f.meta['content_type'].try(:match, 'image/') }
                  end

    {
      arthor: arthor,
      title: title,
      post_at: post_at,
      content: content,
      comments_count: comments_count,
      keywords: keywords,
      link: link,
      event_id: event_id,
      source_type: 'ptt',
      pic_links: pic_links
    }
  end

  def comment_params(doc)
    if doc.css('.push-ipdatetime').text.match(/^\d{2}\/\d{2} \d{2}:\d{2}/)
      commented_at = Time.parse(doc.css('.push-ipdatetime').text[0..10])
    else
      commented_at = nil
    end

    {commenter: doc.css('.push-userid').text, comment: doc.css('.push-content').text[1..-1], commented_at: commented_at}
  end
end
