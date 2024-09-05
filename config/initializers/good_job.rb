# config/initializers/good_job.rb

Rails.application.configure do
  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = true
  config.good_job.queues = '*'
  config.good_job.max_threads = ENV.fetch("RAILS_MAX_THREADS") { 2 }.to_i
  config.good_job.poll_interval = 30 # seconds
  config.good_job.shutdown_timeout = 25 # seconds
  config.good_job.enable_cron = false
end