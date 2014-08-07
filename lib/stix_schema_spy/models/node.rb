# Generic Node (Element or Attribute)

module StixSchemaSpy
  class Node
    attr_reader :documentation, :schema, :containing_type

    def initialize(xml, schema, containing_type = nil)
      @xml = xml
      @schema = schema
      @containing_type = containing_type
      @documentation = @xml.xpath('xs:annotation/xs:documentation', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).to_a.map {|node| node.text}.join("\n")
    end

    def link
      type.url
    end

    def reference?
      @xml.attributes['ref'] != nil
    end

    def element?
      !attribute?
    end

    def type
      @type ||= type!
    end

    def type!
      if reference?
        if referenced_element
          referenced_element.type.use(self)
        else        
          ExternalType.new(*@xml.attributes['ref'].value.split(':')).use(self)
        end
      elsif named_type = @xml.attributes['type']
        type = schema.find_type(named_type.value) || Type.find(named_type.value, nil, stix_version)
        type.use(self)
      else
        Type.inline(@xml, self.schema, self.name).use(self)
      end
    end

    def name
      @name ||= name!
    end

    def name!
      if reference?
        @xml.attributes['ref'].value.split(':').last
      else
        @xml.attributes['name'].value
      end
    end

    # Only valid if this is a reference. Also works for attributes, this was a crappy name
    def referenced_element
      ref = @xml.attributes['ref'].value
      @referenced_element ||= if ref =~ /:/
        prefix, element = ref.split(':')
        schema.find_element(element) || schema.find_attribute("@#{element}") if schema = Schema.find(prefix)
      else
        self.schema.find_element(ref) || self.schema.find_attribute("@#{ref}")
      end
    end

    def inspect
      "#<#{self.class.to_s}:#{object_id} @name=\"#{name}\">"
    end

    def stix_version
      schema.stix_version
    end
  end
end