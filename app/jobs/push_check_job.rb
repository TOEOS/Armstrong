class PushCheckJob < ActiveJob::Base
  queue_as :default

  def perform(options={})
    puts "PushCheckJob: enter: #{Time.now}"
    puts "PushCheckJob: leave: #{Time.now}"
  end
end
