# A STIX/CybOX/etc XML Schema
# This is the centerpiece of most of the parsing

require 'json'

module StixSchemaSpy
  class Schema

    VERSIONS = ['1.1.1', '1.1', '1.0.1', '1.0']

    include StixSchemaSpy::HasChildren
    include StixSchemaSpy::Util::SchemaNaming

    @@schemas = {}
    @@schemas_by_file = {}
    @@config = JSON.parse(File.read(File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', 'config', 'mappings.json')))
    attr_reader :doc, :prefix, :types, :namespace, :filename, :stix_version

    @schema_root = {
      stix: 'http://stix.mitre.org/XMLSchema',
      cybox: 'http://cybox.mitre.org/XMLSchema'
    }

    def initialize(schema_location, version = self.latest_version)
      # Open the schema
      @filename = schema_location.split(/[\/\\]/).last
      @doc = Nokogiri::XML(open(schema_location))

      @elements = {}
      @attributes = {}
      @types = {}
      @special_fields = []
      @stix_version = version

      # Find this document's prefix (if any)
      @namespace = doc.root.attributes['targetNamespace'].value
      @prefix = find_prefix(doc)
      @@schemas[version] ||= {}
      @@schemas[version][prefix] = self

      # First, process any schemas that this schema imports (unless they're blacklisted)
      path = schema_location.split('/')[0...-1].join('/')
      doc.xpath('//xs:import', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).each do |import|
        if self.class.config['schemas'][import.attributes['namespace'].value] && lp = Schema.config['schemas'][import.attributes['namespace'].value]['localPath']
          schema_location = "config/schemas/#{lp}"
        else
          schema_location = import.attributes['schemaLocation'].value
          schema_location = "#{path}/#{schema_location}" unless (schema_location =~ /http/)
        end
        self.class.build(schema_location, version) unless self.class.blacklisted?(import.attributes['namespace'].value)
      end

      doc.xpath('//xs:include', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).each do |include_elem|
        schema_location = include_elem.attributes['schemaLocation'].value
        schema_location = "#{path}/#{schema_location}" unless (schema_location =~ /http/)
        @@schemas_by_file[version] ||= {}
        @@schemas_by_file[version][schema_location.split('/').last] = :imported
        process_doc(Nokogiri::XML(open(schema_location)))
      end

      process_doc(@doc)
    end

    def process_doc(doc)
      doc.xpath('/xs:schema/*', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).each do |field|
        process_field(field)
      end
    end

    # Get the configuration entry for this schema
    def config
      @@config['schemas'][namespace] || {}
    end

    # This makes the has_children module work a little easier (doesn't have to know the difference)
    # between schemas and types.
    def schema
      self
    end

    # Again, just for compatibility with Type
    def parent_type
      false
    end

    # More compatibility with type
    def load!
      # Schemas are automatically loaded, so do nothing
    end

    # Find the version of this schema by looking at the version attribute
    def version
      doc.root.attributes['version'].value || "Unknown"
    end

    # Find the namespace prefix by searching through the namespaces for the TNS
    def find_prefix(doc)
      return config['prefix'] if config && config['prefix']

      # Loop through the attributes until we see one with the same value
      ns_prefix_attribute = doc.namespaces.find do |prefix, ns|
        ns.to_s == namespace.to_s && prefix != 'xmlns'
      end

      # If the attribute was found, return it, otherwise return nil
      ns_prefix_attribute ? ns_prefix_attribute[0].split(':').last : "Unknown"
    end

    # Find a type in this schema by name
    def find_type(name)
      @types[name]
    end

    # Returns the path to the documentation, just by looking it up in the config
    def doc_path
      config['docs']
    end

    # Returns whether the schema is a CybOX object
    def is_cybox_object?
      namespace =~ /objects#/
    end

    def complex_types
      @types.values.select {|t| t.kind_of?(ComplexType)}
    end

    def simple_types
      @types.values.select {|t| t.kind_of?(SimpleType)}
    end

    # Build a new schema, cache it
    def self.build(schema_location, version = self.latest_version)
      filename = schema_location.split('/').last
      if filename == 'generic.xsd'
        filename = schema_location.split('/')[-2..-1].join('/')
      end
      @@schemas_by_file[version] ||= {}
      @@schemas_by_file[version][filename] ||= self.new(schema_location, version)
    end

    def self.schemas_by_file
      @@schemas_by_file
    end

    # Return the schemas configuration hash
    def self.config
      @@config
    end

    # Get all schemas
    def self.all(version = self.latest_version)
      @@schemas[version].values
    end

    # Find a schema by prefix
    def self.find(prefix_or_ns, version = self.latest_version)
      @@schemas[version] ||= {}
      if @@schemas[version][prefix_or_ns]
        @@schemas[version][prefix_or_ns]
      elsif schema_mapping = self.config['schemas'][prefix_or_ns]
        @@schemas[version][schema_mapping['prefix']]
      end
    end

    def self.namespaces
      self.all.inject({'xs' => 'http://www.w3.org/2001/XMLSchema', 'xsi' => 'http://www.w3.org/2001/XMLSchema-instance'}) {|coll, schema| coll[schema.prefix] = schema.namespace; coll}
    end

    def self.schema_dir(version = self.latest_version)
      File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', 'config', version)
    end

    def self.latest_version
      "1.1.1"
    end

    def latest_version
      self.class.latest_version
    end

    # Don't process non STIX or CybOX schemas
    def self.blacklisted?(namespace)
      blacklist_enabled? && (namespace =~ /(stix)|(cybox)|(data-marking)/).nil?
    end

    def self.blacklist_enabled?
      !!@blacklist_enabled
    end

    def self.blacklist_enabled=(val)
      @blacklist_enabled = val
    end

    def preload!
      100.times do
        schema.elements.map(&:type)
        schema.attributes.map(&:type)
        schema.complex_types.each {|t| t.elements.each(&:type)}
      end
    end

    def self.preload!(version = self.latest_version)
      @preloaded ||= {}
      return if @preloaded[version]
      @preloaded[version] = true
      Dir.glob("#{schema_dir(version)}/stix/cybox/*.xsd").each {|f| self.build(f, version)}
      Dir.glob("#{schema_dir(version)}/stix/cybox/objects/*.xsd").each {|f| self.build(f, version)}
      Dir.glob("#{schema_dir(version)}/stix/cybox/extensions/*.xsd").each {|f| self.build(f, version)}
      Dir.glob("#{schema_dir(version)}/stix/*.xsd").each {|f| self.build(f, version)}
      Dir.glob("#{schema_dir(version)}/stix/extensions/**/*.xsd").each {|f| self.build(f, version)}
      @uber_schema = Dir.chdir(schema_dir(version)) {Nokogiri::XML::Schema.new(File.read('uber_schema.xsd'))}
      Schema.all(version).each(&:preload!)
      return true
    end

    def self.schema_root
      @schema_root
    end

    def self.schema_root=(value)
      @schema_root = value
    end

    def blacklisted?
      self.class.blacklisted?(self.namespace)
    end

    self.blacklist_enabled = true
  end
end
