# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

gem 'rails', '~> 5.2.4', '>= 5.2.4.1'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 4.3'
gem 'sqlite3'

gem 'jbuilder', '~> 2.5'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 5.x'

group :development, :test do
  gem 'debase', '~> 0.2.4.1'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.9.1'
  gem 'ruby-debug-ide', '~> 0.7.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'chromedriver-helper'
  gem 'selenium-webdriver'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
