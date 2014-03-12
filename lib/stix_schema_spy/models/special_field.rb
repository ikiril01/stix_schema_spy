# Represents some weird XML construct we don't handle (xs:any, xs:anyAttribute primarily)

module StixSchemaSpy
  class SpecialField

    attr_accessor :name, :type, :documentation

    def initialize(name)
      @name = name
      @type = ExternalType.new("", "")
    end

    def attribute?
      false
    end

    def element?
      true
    end
  end
end