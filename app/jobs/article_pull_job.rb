class ArticlePullJob < ActiveJob::Base
  queue_as :default

  def perform(crawler)
    puts "ArticlePullJob: enter: #{Time.now}"
    crawler.call
    puts "ArticlePullJob: leave: #{Time.now}"
  end
end
