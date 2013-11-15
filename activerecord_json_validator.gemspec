# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/json_validator/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord_json_validator'
  spec.version       = ActiveRecord::JSONValidator::VERSION
  spec.authors       = ['Rémi Prévost']
  spec.email         = ['rprevost@mirego.com']
  spec.description   = 'ActiveRecord::JSONValidator makes it easy to validate JSON attributes with a JSON schema.'
  spec.summary       = spec.description
  spec.homepage      = 'https://open.mirego.com/activerecord_json_validator'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'activesupport', '>= 3.0.0'

  spec.add_dependency 'json-schema', '~> 2.1'
  spec.add_dependency 'activerecord', '>= 3.0.0'
end
