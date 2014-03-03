require 'rspec'

require 'stix_schema_spy'
include StixSchemaSpy

RSpec.configure do |config|
  config.include StixSchemaSpy
end