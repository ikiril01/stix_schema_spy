# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stix_schema_spy/version'

Gem::Specification.new do |spec|
  spec.name          = "stix_schema_spy"
  spec.version       = StixSchemaSpy::VERSION
  spec.authors       = ["John Wunder"]
  spec.email         = ["jwunder@mitre.org"]
  spec.description   = %q{Contains helpers for working with the STIX and CybOX schemas}
  spec.summary       = %q{Contains helpers for working with the STIX and CybOX schemas}
  spec.homepage      = "http://stix.mitre.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'rake'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
end