class EventCheckJob < ActiveJob::Base
  queue_as :default

  def perform(options={})
    puts "EventCheckJob: enter: #{Time.now}"
    puts "EventCheckJob: leave: #{Time.now}"
  end
end
