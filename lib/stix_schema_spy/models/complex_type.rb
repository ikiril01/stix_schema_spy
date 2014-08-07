# Representation of a ComplexType

module StixSchemaSpy
  class ComplexType < Type

    include StixSchemaSpy::HasChildren

    def initialize(*args)
      @attributes = {}
      @elements = {}
      @types = {}
      @special_fields = []
      super
    end

    def load!
      return if @loaded
      @xml.elements.each {|child| process_field(child) }
      @loaded = true
    end

    # Build a new complex type by trying to find special classes and either using those or the generic type
    def self.build(xml, schema)
      ComplexType.new(xml, schema)
    end

    # Returns whether or not this type is a complex type
    def complex?
      true
    end

    # Complex types can't be enumerations?
    def enumeration?
      false
    end

    # Only valid for vocabularies

    # Returns a list of possible values for that vocabulary
    def vocab_values
      type = Schema.find(self.schema.prefix, stix_version).find_type(name.gsub("Vocab", "Enum"))

      if type
        type.enumeration_values
      else
        raise "Unable to find corresponding enumeration for vocabulary"
      end
    end
  end
end