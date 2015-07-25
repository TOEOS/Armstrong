class ArticleDetectJob < ActiveJob::Base
  queue_as :default


  def perform
    puts "ArticleDetectJob: enter: #{Time.now}"
    NewArticleCrawler.spawn_json(4).each do |crawler_json|
      ArticlePullJob.perform_later(crawler_json)
    end
    puts "ArticleDetectJob: leave: #{Time.now}"
  end
end
