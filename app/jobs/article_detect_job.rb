class ArticleDetectJob < ActiveJob::Base
  queue_as :default

  def perform
    puts "ArticleDetectJob: enter: #{Time.now}"
    NewArticleCrawler.call
    puts "ArticleDetectJob: leave: #{Time.now}"
  end

  def after_perform
    puts "ArticleDetectJob: after_perform: #{Time.now}"
    NewArticleCrawler.spawn(4).each do |crawler|
      ArticlePullJob.perform_later(crawler)
    end
  end
end
