class CommentCheckJob < ActiveJob::Base
  queue_as :default

  def perform
    puts "CommentCheckJob: enter: #{Time.now}"
    EventCommentsCrawler.spawn_json(4).each do |crawler_json|
      CommentUpdateJob.perform_later(crawler_json)
    end
    puts "CommentCheckJob: leave: #{Time.now}"
  end
end
