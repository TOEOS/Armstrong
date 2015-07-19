class PostDetectJob < ActiveJob::Base
  queue_as :default

  def perform
    puts "PostDetectJob: enter: #{Time.now}"
    sleep 150
    puts "PostDetectJob: leave: #{Time.now}"
  end
end
