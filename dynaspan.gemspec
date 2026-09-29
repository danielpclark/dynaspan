# frozen_string_literal: true

require_relative 'lib/dynaspan/version'

Gem::Specification.new do |spec|
  spec.name        = 'dynaspan'
  spec.version     = Dynaspan::VERSION
  spec.authors     = ['Daniel P. Clark']
  spec.email       = ['6ftdan@gmail.com']
  spec.summary     = 'Click-to-edit, in-place AJAX text editing for Rails.'
  spec.description = 'Dynaspan renders plain text that turns into a text field, text area or select when clicked, ' \
                     'and saves the change over AJAX when the field loses focus. No jQuery required.'
  spec.homepage    = 'https://github.com/danielpclark/dynaspan'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.metadata = {
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['{app,config,lib}/**/*', 'CHANGELOG.md', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 7.1', '< 9'
  spec.add_dependency 'actionview', '>= 7.1', '< 9'
  spec.add_dependency 'railties', '>= 7.1', '< 9'
end
