
set :output, "./log/cron_log.log"
#job_type :job, "cd :path && :environment_variable=:environment bundle exec scripts/sidekiq_pusher.rb :task :output"

every 2.minutes do
  rake 'jobs:post_detect'
end
