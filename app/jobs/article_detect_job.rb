class ArticleDetectJob < ActiveJob::Base
  queue_as :default


  def perform
    puts "ArticleDetectJob: enter: #{Time.now}"
    NewArticleCrawler.all
    puts "ArticleDetectJob: leave: #{Time.now}"
  end
end
