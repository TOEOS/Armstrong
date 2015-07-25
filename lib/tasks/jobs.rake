require 'sidekiq/api'

namespace :jobs do
  desc "Start article dectection"
  task :article_detect  => :environment do
    run_limited_job('ArticleDetectJob', 'ArticlePullJob')
  end
  desc "Start event checking"
  task :event_check  => :environment do
    run_limited_job('EventCheckJob', 'EventUpdateJob')
  end
  desc "Start comment checking"
  task :comment_check  => :environment do
    run_limited_job('CommentCheckJob', 'CommentUpdateJob')
  end
end

def run_limited_job(klass, dep_klass = nil)
  is_running = false
  workers = Sidekiq::Workers.new
  workers.each do |process_id, thread_id, work|
    is_running = true if [klass, dep_klass].include?(work['payload']['args'][0]['job_class'])
  end
  klass.constantize.perform_later unless is_running
end
