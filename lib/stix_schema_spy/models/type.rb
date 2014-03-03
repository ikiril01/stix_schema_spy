# Generic Type (ComplexType, SimpleType, or ExternalType)

class StixSchemaSpy::Type

  attr_reader :name, :documentation, :extension, :schema, :inline

  def initialize(xml, schema, inline = false)
    @inline = !!inline
    @schema = schema
    @xml = xml
    @name = xml.attributes['name'] ? xml.attributes['name'].value : "#{inline}InlineType"
    @documentation = xml.xpath('./xs:annotation/xs:documentation', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).text
    @extension = get_extension(xml)
  end

  def full_name
    @inline ? name : "#{prefix}:#{name}"
  end

  def get_extension(type)
    if node = type.xpath('xs:complexContent/xs:extension | xs:simpleContent/xs:extension | xs:complexContent/xs:restriction | xs:simpleContent/xs:restriction', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).first
      base = node.attributes['base'].value
      schema.find_type(base) || Type.find(base)
    else
      nil
    end
  end

  def abstract?
    !!(@xml.attributes['abstract'] && @xml.attributes['abstract'].value == "true")
  end

  def parent_type
    @extension
  end

  # URL is just the prefix/type
  # TODO: This should really go in a helper....
  def url
    "#{prefix}/#{name}"
  end

  # This may be overriden by classes that inherit this. Otherwise it just checks to see if a template exists
  def has_example?
    File.exists?("views/examples/#{prefix}/#{name}.erb")
  end

  # This may be overriden by classes that inherit this. Otherwise it just renders the template
  def example(configuration)
    ERB.new(File.read("views/examples/#{prefix}/#{name}.erb")).result(configuration.get_binding)
  end

  def doc_path
    @schema.doc_path ? @schema.doc_path + "##{name}" : nil
  end

  # Returns whether or not this type is a vocabulary
  def vocab?
    @is_vocab ||= full_name =~ /Vocab-\d\.\d$/
  end

  def self.inline(xml, schema, name)
    type = if complex_type = xml.xpath('xs:complexType', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).first
      ComplexType.new(complex_type, schema, name)
    elsif simple_type = xml.xpath('xs:simpleType', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).first
      SimpleType.new(simple_type, schema, name)
    else
      $logger.warn "Unable to find type for #{xml.attributes['name'].value}" if defined?($logger)
      ExternalType.new("", "")
    end
    schema.types[type.name] = type
    type
  end

  def self.find(prefix, name = nil)
    if name.nil?
      if prefix.split(':').length == 2
        prefix, name = prefix.split(':')
      else
        name = prefix
        prefix = nil
      end
    end
    
    if schema = Schema.find(prefix)
      schema.find_type(name)
    else
      ExternalType.new(prefix, name)
    end
  end

  def prefix
    @schema.prefix
  end

  def self.counter
    @counter ||= 0
    @counter += 1
  end

  def inspect
    "#<#{self.class.to_s}:#{object_id} @name=\"#{full_name}\">"
  end
end