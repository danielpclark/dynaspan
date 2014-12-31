require 'dynaspan/version'


module Dynaspan
  ASSETS = %W(dynaspan/*.js dynaspan/*.css dynaspan/*.png dynaspan/*.gif dynaspan/*.html dynaspan/*.md)
  INITIALIZER = "initializer 'dynaspan.assets.precompile', group: :all do |app| app.config.assets.precompile += Dynaspan::ASSETS; end"

  class Engine < ::Rails::Engine
    isolate_namespace Dynaspan

    eval Dynaspan::INITIALIZER

    initializer 'dynaspan.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Dynaspan::ApplicationHelper
      end
    end

    if ::Rails.version.to_s =~ /^4/
      rake_tasks do
        load "dynaspan/tasks.rake"
      end
    end
  end

  if ::Rails.version.to_s =~ /^3\.[0]/
    class Railtie < ::Rails::Railtie
      eval Dynaspan::INITIALIZER
    end
  end
end

