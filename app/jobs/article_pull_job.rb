class ArticlePullJob < ActiveJob::Base
  queue_as :default

  def perform(json)
    puts "ArticlePullJob: enter: #{Time.now}"
    crawler = NewArticleCrawler.new(links: JSON.parse(json))
    crawler.call
    puts "ArticlePullJob: leave: #{Time.now}"
  end
end
