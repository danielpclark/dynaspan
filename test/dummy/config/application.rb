# frozen_string_literal: true

# A tiny Rails application used by the test suite and the README demo.
require 'fileutils'
require 'logger'
require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'propshaft'
require 'dynaspan'

database = File.expand_path("../db/#{ENV.fetch('RAILS_ENV', 'development')}.sqlite3", __dir__)
FileUtils.rm_f(Dir["#{database}*"])
ENV['DATABASE_URL'] = "sqlite3:#{database}"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path('..', __dir__)
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = 'dynaspan-dummy-secret-key-base' * 4
    config.hosts.clear
    config.logger = ENV['DUMMY_LOG'] ? Logger.new($stdout) : Logger.new(nil)
    config.active_support.deprecation = :stderr
    config.action_controller.allow_forgery_protection = true
  end
end
