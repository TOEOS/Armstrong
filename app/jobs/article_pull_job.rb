class ArticlePullJob < ActiveJob::Base
  queue_as :default

  def perform
    puts "ArticlePullJob: enter: #{Time.now}"
    puts "ArticlePullJob: leave: #{Time.now}"
  end
end
