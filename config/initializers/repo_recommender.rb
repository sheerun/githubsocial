require 'redmon/config'
require 'redmon/redis'
require 'redmon/app'

Redmon.configure do |config|
  config.redis_url = ENV['REDIS_URL'] || 'redis://127.0.0.1:6379'
  config.namespace = 'redmon'
end
