require 'raven'

Raven.configure do |config|
  config.dsn = ENV['RAVEN_DSN']
  config.environments = %w[ production ]
  config.current_environment = Rails.env
  config.tags = { environment: Rails.env }
  config.excluded_exceptions = []
end
