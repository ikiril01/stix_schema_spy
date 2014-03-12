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