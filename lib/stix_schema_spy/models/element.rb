# Representation of an Element (type of Node)

require_relative 'node'

module StixSchemaSpy
  class Element < StixSchemaSpy::Node
    def attribute?
      false
    end

    def min_occurs
      @xml.attributes['minOccurs'] ? @xml.attributes['minOccurs'].value : "1"
    end

    def max_occurs
      @xml.attributes['maxOccurs'] ? @xml.attributes['maxOccurs'].value : "1"
    end
  end
end