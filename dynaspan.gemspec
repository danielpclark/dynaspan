# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dynaspan/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Daniel P. Clark']
  gem.email         = ['6ftdan@gmail.com']
  gem.description   = %q{In place text editing with AJAX substituting text to input field.}
  gem.summary       = %q{Text to AJAX editing in place.}
  gem.homepage      = 'https://github.com/danielpclark/dynaspan'
  gem.licenses      = ['MIT']
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'dynaspan'
  gem.require_paths = ['lib']
  gem.required_ruby_version = '~> 2.0'
  gem.version       = Dynaspan::VERSION
end
