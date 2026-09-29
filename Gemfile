# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

rails_version = ENV.fetch('RAILS_VERSION', nil)
gem 'rails', rails_version ? "~> #{rails_version}.0" : '>= 7.1'
gem 'sqlite3', rails_version == '7.1' ? '~> 1.4' : '>= 2.1'

gem 'capybara', '>= 3.39'
gem 'cuprite', '>= 0.15'
gem 'minitest', '>= 5.20'
gem 'propshaft'
gem 'puma', '>= 6.0'
gem 'rake', '>= 13.0'
