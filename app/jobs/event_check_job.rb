class EventCheckJob < ActiveJob::Base
  queue_as :default

  def perform
    puts "EventCheckJob: enter: #{Time.now}"
    EventMonitorCrawler.spawn_json(4).each do |crawler_json|
      EventUpdateJob.perform_later(crawler_json)
    end
    puts "EventCheckJob: leave: #{Time.now}"
  end
end
