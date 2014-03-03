# Represents some weird XML construct we don't handle (xs:any, xs:anyAttribute primarily)

class StixSchemaSpy::SpecialField

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