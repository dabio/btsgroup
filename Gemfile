source :rubygems

gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-r18n', require: 'sinatra/r18n'
gem 'slim'
gem 'sass'
gem 'rack-force_domain'
gem 'rack-timeout', require: 'rack/timeout'
gem 'dm-aggregates'
gem 'dm-core'
gem 'dm-migrations'
gem 'dm-timestamps'
gem 'dm-validations'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'newrelic_rpm'
gem 'unidecode'
gem 'json'

group :development, :test do
  gem 'dm-sqlite-adapter'
  gem 'heroku', require: false
  gem 'shotgun', require: false
  gem 'simplecov', require: false
  gem 'rack-test', require: false
end

group :production do
  gem 'dm-postgres-adapter'
end

