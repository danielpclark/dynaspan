module Dynaspan
  class Engine < ::Rails::Engine
    isolate_namespace Dynaspan

    initializer 'dynaspan.assets.precompile', group: :all do |app|
      app.config.assets.precompile += %W(
        dynaspan/*.js
        dynaspan/*.css
        dynaspan/*.png
        dynaspan/*.gif
        dynaspan/*.html
        dynaspan/*.md
      )
    end

    initializer 'dynaspan.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Dynaspan::ApplicationHelper
      end
    end

  end
end
