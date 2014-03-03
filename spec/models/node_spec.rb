require 'spec_helper'

describe Node do
  context "The Node class" do
    it "should be able to create itself from schema" do
      @doc = Nokogiri::XML(open('config/schemas/stix/stix_core.xsd'))
      node = Node.new(@doc.xpath('//xs:element').first, self)

      node.documentation.should == "The STIX_Package field contains a bundle of information characterized in the Structured Threat Information eXpression (STIX) language."
    end
  end

  context "A node with a defined type" do
    before do
      @schema = Schema.build('config/schemas/stix/stix_core.xsd')
      @stix_package = @schema.find_element('STIX_Package')
    end

    it "should be able to find its type" do
      @stix_package.type.should == @schema.find_type('STIXType')
    end

    it "should be an element or attribute as appropriate" do
      @stix_package.should be_element
      @stix_package.type.attributes.first.should be_attribute
    end

    it "should have the given name" do
      @stix_package.name.should == "STIX_Package"
    end
  end

  context "A node with a referenced type" do
    before do
      @schema = Schema.build("config/schemas/cybox/cybox_core.xsd")
      @observable = @schema.find_type("ObservablesType").find_element('Observable')
    end

    it "should have an anonymous type" do
      @observable.type.should == @schema.find_type("ObservableType")
    end
  end

  context "A node with an inline type" do

  end
end