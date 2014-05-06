# Representation of a type that is not contained within the schemas available to this app

module StixSchemaSpy
  class ExternalType
    attr_reader :name

    def initialize(prefix, name)
      @prefix = prefix
      @name = name
    end

    def prefix
      @prefix || ""
    end

    # For compatibility w/ normal types
    def use(by)
      return self
    end

    def usages
      []
    end

    def own_usages
      []
    end

    def use_parent(child)
      self
    end

    def child_types
      []
    end

    def abstract?
      false
    end

    def has_own_fields?
      false
    end

    def full_name
      if prefix && prefix.length > 0
        "#{prefix}:#{name}"
      else
        name
      end
    end

    def documentation
      ""
    end

    def has_example?
      false
    end

    def fields
      []
    end

    def attributes
      []
    end

    def elements
      []
    end

    def url
      nil
    end
  end
end