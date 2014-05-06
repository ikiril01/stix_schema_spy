module StixSchemaSpy
  module HasChildren
    def find_element(name, all = true)
      load!
      if @elements[name]
        @elements[name]
      elsif parent_type && all
        parent_type.find_element(name)
      else
        nil
      end
    end

    def find_attribute(name, all = true)
      load!
      if @attributes[name]
        @attributes[name]
      elsif parent_type && all
        parent_type.find_attribute(name)
      else
        nil
      end
    end

    def elements(all = true)
      load!
      (@elements.values + (all && parent_type ? parent_type.elements : []))
    end

    def attributes(all = true)
      load!
      (@attributes.values + (all && parent_type ? parent_type.attributes : []))
    end

    def own_fields
      load!
      attributes(false) + elements(false) + @special_fields
    end

    def fields
      load!
      (parent_type ? parent_type.fields : []) + own_fields
    end
    
    #################################################################################################
    private
    #################################################################################################

    # Runs through the list of fields under this type and creates the appropriate objects
    def process_field(child)
      if ['complexContent', 'simpleContent', 'sequence', 'group', 'choice', 'extension'].include?(child.name)
        child.elements.each {|grandchild| process_field(grandchild)}
      elsif child.name == 'element'
        element = Element.new(child, self.schema, self)
        @elements[element.name] = element
      elsif child.name == 'attribute'
        attribute = Attribute.new(child, self.schema, self)
        @attributes[attribute.name] = attribute
      elsif child.name == 'complexType'
        type = ComplexType.build(child, self.schema)
        @types[type.name] = type
      elsif child.name == 'simpleType'
        type = SimpleType.build(child, self.schema)
        @types[type.name] = type
      elsif child.name == 'anyAttribute'
        @special_fields << SpecialField.new("##anyAttribute")
      elsif child.name == 'anyElement'
        @special_fields << SpecialField.new("##anyElement")
      elsif child.name == 'attributeGroup'
        # The only special case here...essentially we'll' transparently roll attribute groups into parent nodes,
        # while at the schema level global attribute groups get created as a type
        if self.kind_of?(Schema)
          type = ComplexType.build(child, self.schema)
          @types[type.name] = type
        else
          Type.find(child.attributes['ref'].value).attributes.each {|attrib| @attributes[attrib.name] = attrib}
        end
      else
        $logger.debug "Skipping: #{child.name}" if defined?($logger)
      end
    end
  end
end