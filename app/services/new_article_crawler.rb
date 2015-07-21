# How to Use
# 1. crawl all new articles
#   NewArticleCrawler.call
#   or
#   NewArticleCrawler.new.call
# 2. crawl all new articles in n batch
#   new_article_crawlers = NewArticleCrawler.spawn(4)
#   #=> [#<NewArticleCrawler>, #<NewArticleCrawler>, #<NewArticleCrawler>, #<NewArticleCrawler>]
#   new_article_crawlers.each(&:call)
#   #=> crawlers will crawl each by each
#

class NewArticleCrawler
  class << self
    def call
      new.call
    end

    def spawn(number)
      newest_three_articles = Article.select(:title, :post_at).order(post_at: :desc).limit(3)

      last_article_date = newest_three_articles.first.try(:post_date) || Date.today.strftime("%_m/%d")
      
      newest_three_article_titles = newest_three_articles.map(&:title)

      find_newest_article_date_page(last_article_date)

      links = []

      links.push(*(find_newest_article_page(newest_three_article_titles, for_spwan: true))) if newest_three_articles.any?

      links.push(*crawl_new_articles(for_spwan: true))

      links.each_slice(links.length / number + 1).to_a.map {|group_of_links| new(group_of_links) }
    end
  end

  def initialize(links = nil)
    @links = links
    @configs = {
      page_number: 9800,
      find_newest_article_date_page: false,
      find_newest_article_page: false
    }
  end

  def call
    if @links
      @links.each {|link| crawl_artcile(link)}
    else
      newest_three_articles = Article.select(:title, :post_at).order(post_at: :desc).limit(3)

      last_article_date = newest_three_articles.first.try(:post_date) || Date.today.strftime("%_m/%d")
      
      newest_three_article_titles = newest_three_articles.map(&:title)

      find_newest_article_date_page(last_article_date)

      find_newest_article_page(newest_three_article_titles) if newest_three_articles.any?

      crawl_new_articles
    end
  end

  def find_newest_article_date_page(last_article_date)
    while @configs[:find_newest_article_date_page]
      ptt_url = "https://www.ptt.cc/bbs/Gossiping/index#{@configs[:page_number]}.html"

      doc = Nokogiri::HTML(open(ptt_url, 'Cookie'=> 'over18=1'))

      article_days = doc.css('.r-ent').css('.meta').css('.date').map(&:text).uniq

      article_days.include?(last_article_date) ?
        @configs[:find_article_date_page] = true :
        @configs[:page_number] += 1
    end
  end

  def find_newest_article_page(newest_three_article_titles, for_spwan: false)
    while @configs[:find_newest_article_page]
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

        return new_articles_links if for_spwan

        new_articles_links.each do |link|
          crawl_artcile(link)
        end

        @configs[:find_newest_article_page] = true
        @page_number += 1
      else
        @page_number += 1
      end
    end
  end

  def crawl_new_articles(for_spwan: false)
    links = []
    while true
      ptt_url = "https://www.ptt.cc/bbs/Gossiping/index#{@configs[:page_number]}.html"  

      begin
        doc = Nokogiri::HTML(open(ptt_url, 'Cookie'=> 'over18=1'))
      rescue
        @configs[:page_number] -= 1
        return links if for_spwan
        break
      end

      new_articles_links = doc.css('.r-ent').css('.title').xpath('a').
                               select {|a_tag| a_tag.text.match(/新聞|爆[卦掛]/)}.
                               map {|a_tag| a_tag[:href]}

      if for_spwan
        links.push(*new_articles_links)
      else
        new_articles_links.each do |link|
          crawl_artcile(link)
        end
      end

      @configs[:page_number] += 1
    end
  end

  def crawl_artcile(link, crawl_comments: true)
    doc = Nokogiri::HTML(open('https://www.ptt.cc/'+link, 'Cookie'=> 'over18=1')).css('#main-container').css('#main-content')

    article = Article.create(article_params(doc))

    if crawl_comments
      article_id = article.id

      comments = doc.css('.push')

      comments.each {|c| Comment.create(article_id: article_id, **comment_params) }
    end
  end

  private

  def article_params(doc)
    arthor = doc.css('.article-metaline')[0].css('.article-meta-value').text

    title = doc.css('.article-metaline')[1].css('.article-meta-value').text

    post_at = Time.parse(doc.css('.article-metaline')[2].css('.article-meta-value').text)

    doc.css('.article-metaline, .article-metaline-right').remove

    content = doc.text.split('--').first

    {arthor: arthor, title: title, post_at: post_at, content: content}
  end

  def comment_params(doc)
    {commenter: doc.css('.push-userid').text, comment: doc.css('.push-content').text}
  end
end
