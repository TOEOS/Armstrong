# -*- encoding : utf-8 -*-
namespace :jieba do
  desc "Start Jieba bridge daemon"
  task :start  => :environment do
    jieba_path = Rails.root.join('lib/python')
    ENV['jeiba_pid'] = spawn("python #{jieba_path}/jieba_bridge.py #{jieba_path}").to_s
  end

  desc "Stop Jieba bridge daemon"
  task :stop  => :environment do
    Process.kill("TERM", ENV['jeiba_pid'].to_i) if ENV['jeiba_pid'].present?
  end
end
