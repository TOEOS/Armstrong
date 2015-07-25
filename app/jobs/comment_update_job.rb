class CommentUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(json)
    puts "CommentUpdateJob: enter: #{Time.now}"
    crawler = EventCommentsCrawler.new(JSON.parse(json))
    crawler.call
    puts "CommentUpdateJob: leave: #{Time.now}"
  end
end
