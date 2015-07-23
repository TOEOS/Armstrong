require 'sidekiq/api'

namespace :jobs do
  desc "Start post dectection"
  task :post_detect  => :environment do
    run_limited_job('PostDetectJob')
  end
  desc "Start event checking"
  task :event_check  => :environment do
    run_limited_job('EventCheckJob')
  end
  desc "Start push checking"
  task :push_check  => :environment do
    run_limited_job('PushCheckJob')
  end
end

def run_limited_job(klass)
  is_running = false
  workers = Sidekiq::Workers.new
  workers.each do |process_id, thread_id, work|
    is_running = true if work['payload']['args'][0]['job_class'] == klass
  end
  klass.constantize.perform_later unless is_running
end
