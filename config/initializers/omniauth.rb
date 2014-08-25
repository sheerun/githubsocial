Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

OmniAuth.config.logger = Rails.logger

OmniAuth.config.failure_raise_out_environments = []

OmniAuth.config.on_failure = Proc.new do |env|
  SessionsController.action(:failure).call(env)
end
