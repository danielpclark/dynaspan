# frozen_string_literal: true

require 'rails'

module Dynaspan
  class Engine < ::Rails::Engine
    isolate_namespace Dynaspan

    ASSETS = %w[dynaspan/dynaspan.js dynaspan/dynaspan.css].freeze

    # Make the view helpers available in every view of the host application.
    initializer 'dynaspan.helpers' do
      ActiveSupport.on_load(:action_view) do
        include Dynaspan::ApplicationHelper
      end
    end

    # Sprockets needs to be told about stand-alone assets. Propshaft serves
    # everything in the engine's app/assets directories automatically.
    initializer 'dynaspan.assets' do |app|
      if app.config.respond_to?(:assets)
        precompile = app.config.assets.precompile
        precompile.concat(ASSETS) if precompile.respond_to?(:concat)
      end
    end

    # With importmap-rails, `import "dynaspan"` works without any extra pins.
    initializer 'dynaspan.importmap', before: 'importmap' do |app|
      app.config.importmap.paths << root.join('config/importmap.rb') if app.config.respond_to?(:importmap)
    end
  end
end
