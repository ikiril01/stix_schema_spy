# SchemaIdentifier is a set of methods added to the schema class that help identify
# the type of schema: is it a STIX component, STIX extension, CybOX object, etc.

module StixSchemaSpy
  module Util
    module SchemaNaming

      PROJECT_NAMES = {
        cybox: 'CybOX',
        stix: 'STIX'
      }

      EXTENSION_TYPE = {
        'ap' => 'attack_pattern',
        'structuredcoa' => 'structured_coa',
        'testmechanism' => 'test_mechanism',
        'markingstructure' => 'marking'
      }

      # Returns a symbol indicating the type of schema:
      # One of: core, common, vocabularies, component, object, extension, nil (external)
      def type
        case namespace
        when /stix-\d/, /cybox-\d/
          :core
        when /common/
          :common
        when /vocabularies/
          :vocabularies
        when /cybox\.mitre\.org\/objects#/
          :object
        when /\.mitre\.org\/extensions\//
          :extension
        when /stix\.mitre\.org/ # If it's STIX and not core, common, vocabs, or extensions, it's a component
          :component
        when 'http://data-marking.mitre.org/Marking-1'
          :marking
        else
          nil
        end
      end

      # Returns a symbol indicating whether the schema is STIX or CybOX
      # One of: stix, cybox, nil
      def project
        case namespace
        when /cybox/
          :cybox
        when /stix/, /data-marking/
          :stix
        else
          nil
        end
      end

      def title
        return config['title'] if config['title']
        case type
        when :core, :common, :vocabularies
          "#{PROJECT_NAMES[project]} #{type.to_s.capitalize}"
        when :object, :component
          name = xpath_name.gsub("STIX ", "").gsub("CybOX ", "").gsub("_", " ")
          name == "COA" ? "Course of Action" : name
        when :extension
          match = (xpath_name || "").match(/- ([\w \.]+)( Instance)?/)
          match ? match[1] : nil
        when :marking
          "Data Markings"
        else
          prefix.capitalize
        end
      end

      def schema_location
        return config['schemaLocation'] if config['schemaLocation']
        root = Schema.schema_root[project]
        case type
        when :core, :common
          "#{root}/#{type}/#{version}/#{project}_#{type}.xsd"
        when :vocabularies
          "#{root}/default_#{type}/#{version}/#{project}_default_#{type}.xsd"
        when :component
          component = title.downcase.gsub(' ', '_').downcase
          "#{root}/#{component}/#{version}/#{component}.xsd"
        when :object
          object_name = namespace.match(/#(.+)Object/)[1].gsub(/([^ ])([A-Z][a-z])/, '\1_\2')
          "#{root}/objects/#{object_name}/#{version}/#{object_name}_Object.xsd"
        when :marking
          "#{root}/data_marking/#{version}/data_marking.xsd"
        when :extension
          extension_type = namespace.match(/\/(\w+)#/)[1].downcase
          extension_type = EXTENSION_TYPE[extension_type] if EXTENSION_TYPE[extension_type]
          extension_name = self.filename.gsub("_" + extension_type, '').gsub('.xsd', '')
          "#{root}/extensions/#{extension_type}/#{extension_name}/#{version}/#{extension_name}_#{extension_type}.xsd"
        else
          nil # Fail condition
        end
      end

      def xpath_name
        element = @doc.xpath('/xs:schema/xs:annotation[1]/xs:appinfo/schema', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).first
        element ? element.text : nil
      end
    end
  end
end