# StixSchemaSpy

StixSchemaSpy introspects the STIX and CybOX schemas in order to provide a set of Ruby objects that represent them. These can be used to generate code, documentation, or profiles based on the STIX schemas.

## Installation

Add this line to your application's Gemfile:

    gem 'stix_schema_spy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stix_schema_spy

## Usage

The easiest way to use the code is to preload all schemas referenced by the current version of STIX:

```
require 'stix_schema_spy'

StixSchemaSpy::Schema.preload!
```

You can then use `Schema.find(prefix)` or `Type.find(prefix, type_name)` in order to find specific schemas and types. `Schema.all` and `schema.types` will list all schemas and all types for a given schema, respectively.

A rake task is also available to generate an "uber schema" to validate content against any STIX/CybOX schema. Simply require `stix_schema_spy/util/tasks` and then run `rake stix_schema_spy:generate_schemas[output_dir]`.

Look through the source code and specs for other usage examples.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request