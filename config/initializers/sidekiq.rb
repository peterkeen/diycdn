Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/14' }

  schedule_file = "config/schedule.yml"  

  if File.exist?(schedule_file) && Sidekiq.server?
    puts "loading cron schedule from #{schedule_file}"
    schedule = YAML.load_file(schedule_file)
    pp schedule
    pp Sidekiq::Cron::Job.load_from_hash! schedule
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/14' }
end
