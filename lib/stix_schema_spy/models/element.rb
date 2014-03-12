# Representation of an Element (type of Node)

require_relative 'node'

module StixSchemaSpy
  class Element < StixSchemaSpy::Node
    def attribute?
      false
    end

    def min_occurs
      @xml.attributes['minOccurs'].try(:value) || "1"
    end

    def max_occurs
      case value = @xml.attributes['maxOccurs'].try(:value)
      when nil
        "1"
      when "unbounded"
        "n"
      else
        value
      end
    end
  end
end