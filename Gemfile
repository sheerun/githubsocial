source 'https://rubygems.org'
source 'https://rails-assets.org'

# Core
gem 'rails', '~> 4.1.0'
gem 'pg', '~> 0.17.1'
gem 'figaro', '~> 0.7.0'
gem 'dotenv-rails', '~> 0.11.1'
gem 'yajl-ruby', '~> 1.2.0', :require => 'yajl/json_gem'
gem 'omniauth-github'
gem 'octokit', '~> 3.3.1'
gem 'rake'
gem 'redmon', require: false
gem 'librato-rails'

# Background tasks
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'sidekiq', '~> 3.2.2'
gem 'sidekiq-benchmark'
gem 'sidekiq-failures'

# Frontend
gem 'sass-rails', '5.0.0.beta1'
gem 'uglifier', '~> 2.4'
gem 'coffee-rails', '~> 4.0.0'
gem 'slim-rails', '~> 2.0'
gem 'quiet_assets', '~> 1.0'
gem 'autoprefixer-rails', '~> 3.0.1'
gem 'ngmin-rails', '~> 0.4.0'

# Assets
gem 'rails-assets-angular'
gem 'rails-assets-lodash'
gem 'rails-assets-angular-cache'
gem 'rails-assets-angular-ui-router'
gem 'rails-assets-angular-bootstrap'
gem 'rails-assets-angular-ui-select'
gem 'octicons-rails'

# Import
gem 'oj', '~> 2.10.2'
gem 'hiredis', '~> 0.4.5'
gem 'redis', '~> 3.1.0'
gem 'upsert'

# Error logging
gem "sentry-raven"

group :development do
  gem 'awesome_print'
  gem 'better_errors', :platform => :ruby
  gem 'binding_of_caller', :platform => :ruby

  gem 'pry'
  gem 'pry-doc'
  gem 'pry-byebug'
end

group :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'database_cleaner', '~> 1.2'
end
