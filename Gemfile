source 'https://rubygems.org'

# Core
gem 'rails', '4.1.4'
gem 'pg', '~> 0.17.1'

# Backend
gem 'figaro', '~> 0.7.0'
gem 'dotenv-rails', '~> 0.11.1'
gem 'jbuilder', '~> 2.1.3'
gem 'yajl-ruby', '~> 1.2.0', :require => 'yajl/json_gem'

# Frontend
# For assets precompilation on non-macs install node.js.
# therubyracer is discouraged because of high memory usage.
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '~> 2.4'
gem 'coffee-rails', '~> 4.0.0'
gem 'slim-rails', '~> 2.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 2.2.0'
gem 'quiet_assets', '~> 1.0'

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