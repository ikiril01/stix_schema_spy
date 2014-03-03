require 'spec_helper'

describe Schema do
  context "The Schema class" do
    it "should parse a schema" do
      schema = Schema.build('config/schemas/stix/stix_core.xsd')
      schema.should_not be_nil

      schema.namespace.should == "http://stix.mitre.org/stix-1"
      schema.prefix.should == "stix"
      Schema.find('stix').should == schema

      schema.types.length.should == 11
      schema.elements.length.should == 1
      schema.attributes.length.should == 0
    end

    it "should default the blacklist to true" do
      Schema.blacklist_enabled?.should == true
    end

    it "should be able to enable and disable the blacklist (schemas to ignore)" do
      Schema.blacklist_enabled = false
      Schema.blacklist_enabled?.should == false
    end

    it "should indicate whether a schema is blacklisted" do
      Schema.blacklist_enabled = false
      Schema.blacklisted?("http://stix.mitre.org").should == false
      Schema.blacklisted?("http://iodef.ietf.org").should == false
      Schema.blacklist_enabled = true
      Schema.blacklisted?("http://stix.mitre.org").should == false
      Schema.blacklisted?("http://cybox.ietf.org").should == false
      Schema.blacklisted?("http://data-marking.mitre.org").should == false
      Schema.blacklisted?("http://iodef.ietf.org").should == true
    end

    it "should return namespace mappings" do
      Schema.build('config/schemas/stix/stix_common.xsd')

      Schema.namespaces['xs'].should == 'http://www.w3.org/2001/XMLSchema'
      Schema.namespaces['stixCommon'].should == 'http://stix.mitre.org/common-1'
    end
  end

  context "A schema instance" do
    before do
      @schema = Schema.build('config/schemas/stix/stix_core.xsd')
    end

    it "should be able to find an element" do
      @schema.find_element('STIX_Package').should_not be_nil
    end

    it "should be able to list global elements" do
      @schema.elements.should == [@schema.find_element('STIX_Package')]
    end

    it "should be able to find the schema location" do
      @schema.schema_location.should == 'http://stix.mitre.org/XMLSchema/core/1.1/stix_core.xsd'
    end
  end
end