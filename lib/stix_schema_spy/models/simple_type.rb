# Representation of a simple type

class StixSchemaSpy::SimpleType < StixSchemaSpy::Type

  def self.build(xml, schema)
    self.new(xml, schema)
  end

  # Returns whether or not this simple type is an enumeration
  def enumeration?
    @is_enumeration ||= @xml.xpath('./xs:restriction/xs:enumeration', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).length > 0
  end

  # Returns the list of values for this enumeration
  def enumeration_values
    enumeration = @xml.xpath('./xs:restriction/xs:enumeration', {'xs' => 'http://www.w3.org/2001/XMLSchema'})
    if enumeration.length > 0
      return enumeration.map {|elem| [elem.attributes['value'].value, elem.xpath('./xs:annotation/xs:documentation', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).text]}
    else
      raise "Not an enumeration"
    end    
  end

  # A shortcut to checking whether there's an example because simple types never have examples
  def has_example?
    false
  end

  # Not a complex type
  def complex?
    false
  end

  def fields
    []
  end

  def own_fields
    []
  end

  def elements
    []
  end
end