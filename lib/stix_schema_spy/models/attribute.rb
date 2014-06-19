# Instance of node for attributes

require_relative 'node'

module StixSchemaSpy
  class Attribute < StixSchemaSpy::Node
    def attribute?
      true
    end

    # Attribute names have an @ prefixed
    def name
      "@#{super}"
    end

    def use
      @xml.attributes['use'] ? @xml.attributes['use'].value : "optional"
    end
  end
end