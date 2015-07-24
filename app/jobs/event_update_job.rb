class EventUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(options={})

  end
end
