require 'spec_helper'

describe SimpleType do
  context "The class" do
    it "should be able to create a new complex type from schema" do
      doc = Nokogiri::XML(open('config/schemas/stix/exploit_target.xsd'))
      type = SimpleType.new(doc.xpath('//xs:simpleType').first, self)
    end
  end

  context "instances" do
    before do
      schema = Schema.build('config/schemas/stix/exploit_target.xsd')

      @exploit_target_version = schema.find_type('ExploitTargetVersionType')
      @cvss_score = schema.find_type('CVSSScoreType')
    end

    it "should indicate whether it's an enumeration" do
      @exploit_target_version.should be_enumeration
      @cvss_score.should_not be_enumeration
    end

    it "should have enumeration values if it's an enumeration" do
      @exploit_target_version.enumeration_values.should == [['1.0', ''], ['1.0.1', ''], ['1.1', '']]

      expect {@cvss_score.enumeration_values}.to raise_error
    end

    it "should not have an example" do
      @exploit_target_version.has_example?.should == false
    end

    it "should not be complex" do
      @exploit_target_version.should_not be_complex
    end
  end
end