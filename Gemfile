# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'acts-as-taggable-on', '~> 8.1'
gem 'money'
gem 'parallel'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.4'
gem 'virtus', '~> 2.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'timecop'
end

group :development do
  gem 'listen', '~> 3.3'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
