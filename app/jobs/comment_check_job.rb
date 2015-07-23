class CommentCheckJob < ActiveJob::Base
  queue_as :default

  def perform(options={})
    puts "CommentCheckJob: enter: #{Time.now}"
    puts "CommentCheckJob: leave: #{Time.now}"
  end
end
