require 'dynaspan/version'

module Dynaspan
  case ::Rails.version.to_s
  when /^4/
    require 'dynaspan/engine'
  when /^3\.[12]/
    require 'dynaspan/engine3'
  when /^3\.[0]/
    require 'dynaspan/railtie'
  end
end
