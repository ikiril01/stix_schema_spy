# Instance of node for attributes

require_relative 'node'

class StixSchemaSpy::Attribute < StixSchemaSpy::Node
  def attribute?
    true
  end

  # Attribute names have an @ prefixed
  def name
    "@#{super}"
  end

  def use
    @xml.attributes['use'].try(:value) || "optional"
  end
end