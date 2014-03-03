require 'spec_helper'

describe Type do
  context "The Type class" do
    it "should be able to create a new type" do
      @doc = Nokogiri::XML(open('config/schemas/stix/stix_core.xsd'))
      type = Type.new(@doc.xpath('//xs:complexType').first, self)

      type.name.should == 'STIXType'
      type.documentation.should == "STIXType defines a bundle of information characterized in the Structured Threat Information eXpression (STIX) language."
    end
  end

  context "a type" do
    before do
      @stix_type = Schema.build('config/schemas/stix/stix_core.xsd').find_type('STIXType')
      @activity_type = Schema.build('config/schemas/stix/stix_common.xsd').find_type('ActivityType')
    end

    it "should have various names" do
      @stix_type.name.should == "STIXType"
      @stix_type.full_name.should == "stix:STIXType"

      @activity_type.name.should == "ActivityType"
      @activity_type.full_name.should == "stixCommon:ActivityType"
    end

    it "should be able to determine whether it's abstract" do
      @stix_type.abstract?.should == false
      @activity_type.abstract?.should == true
    end

    it "should have a URL" do
      @stix_type.url.should == "stix/STIXType"
      @activity_type.url.should == "stixCommon/ActivityType"
    end

    it "should delegate schema prefix" do
      @stix_type.prefix.should == "stix"
      @activity_type.prefix.should == "stixCommon"
    end
  end
end