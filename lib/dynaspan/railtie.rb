module Dynaspan
  class Railtie < ::Rails::Railtie
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
  end
end
