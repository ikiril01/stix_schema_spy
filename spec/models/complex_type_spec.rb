require 'spec_helper'

describe ComplexType do
  context "The class" do
    it "should be able to create a new complex type from schema" do
      doc = Nokogiri::XML(open('config/schemas/stix/stix_core.xsd'))
      type = ComplexType.new(doc.xpath('//xs:complexType').first, self)
    end

    it "should create appropriate subclasses" do
      schema = Schema.build('config/schemas/stix/stix_core.xsd')
      doc = Nokogiri::XML(open('config/schemas/stix/stix_core.xsd'))

      type = ComplexType.build(doc.xpath('//xs:complexType')[1], schema)
      type.should be_kind_of ComplexType
    end
  end

  context "instances" do
    before do
      @stix_type             = Schema.build('config/schemas/stix/stix_core.xsd').find_type('STIXType')
      @ttp_type              = Schema.build('config/schemas/stix/ttp.xsd').find_type('TTPType')
      @indicator_type_vocab  = Schema.build('config/schemas/stix/stix_default_vocabularies.xsd').find_type('IndicatorTypeVocab-1.0')
    end

    it "should list its own fields" do
      @stix_type.own_fields.length.should == 14
      @ttp_type.own_fields.length.should == 15

      @stix_type.own_fields.first.should be_kind_of(Node)
    end

    it "should list all of its fields (including inherited)" do
      @stix_type.fields.length.should == 14
      @ttp_type.fields.length.should == 18

      @stix_type.fields.first.should be_kind_of(Node)
    end

    it "should list elements" do
      @stix_type.elements.length.should == 10
      @ttp_type.elements.length.should == 14

      @stix_type.elements.first.should be_kind_of(Element)
    end

    it "should list attributes" do
      @stix_type.attributes.length.should == 4
      @ttp_type.attributes.length.should == 4

      @stix_type.attributes.first.should be_kind_of(Attribute)
    end

    it "should indicate that it's a complex type" do
      @stix_type.should be_complex
    end

    it "should be a vocabulary as appropriate" do
      @stix_type.should_not be_vocab
      @indicator_type_vocab.should be_vocab
    end

    it "should find values for a vocabulary" do
      @indicator_type_vocab.vocab_values.length.should == 10
      expect {@stix_type.vocab_values}.to raise_error
    end
  end
end