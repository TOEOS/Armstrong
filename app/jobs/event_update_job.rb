class EventUpdateJob < ActiveJob::Base
  queue_as :default
  def perform(json)
    puts "EventUpdateJob: enter: #{Time.now}"
    crawler = EventMonitorCrawler.new(JSON.parse(json))
    crawler.call
    puts "EventUpdateJob: leave: #{Time.now}"
  end
end
