require 'spec_helper'

describe Util::SchemaNaming do

  before do
    @class = Class.new
    @class.send(:include, Util::SchemaNaming)

    @schema = @class.new
    @schema.stub(:config).and_return({})

    def type_for(namespace)
      @schema.stub(:namespace).and_return(namespace)
      @schema.type
    end

    def project_for(namespace)
      @schema.stub(:namespace).and_return(namespace)
      @schema.project
    end

    def name_for(namespace)
      @schema.stub(:namespace).and_return(namespace)
      @schema.title
    end

    def location_for(namespace, version="1.1")
      @schema.stub(:namespace).and_return(namespace)
      @schema.stub(:version).and_return(version)
      @schema.schema_location
    end
  end

  context "#type" do
    it "should find core" do
      type_for("http://stix.mitre.org/stix-1").should == :core
      type_for("http://cybox.mitre.org/cybox-2").should == :core
    end

    it "should find common" do
      type_for("http://stix.mitre.org/common-1").should == :common
      type_for("http://cybox.mitre.org/common-2").should == :common
    end

    it "should find vocabularies" do
      type_for("http://stix.mitre.org/default_vocabularies-1").should == :vocabularies
      type_for("http://cybox.mitre.org/default_vocabularies-2").should == :vocabularies
    end

    it "should find objects" do
      type_for("http://cybox.mitre.org/objects#AddressObject-2").should == :object
      type_for("http://cybox.mitre.org/objects#WinNetworkShareObject-2").should == :object
      type_for("http://cybox.mitre.org/objects#FileObject-2").should == :object
      type_for("http://cybox.mitre.org/objects#SocketAddressObject-1").should == :object
    end

    it "should find extensions" do
      type_for("http://stix.mitre.org/extensions/TestMechanism#Snort-1").should == :extension
      type_for("http://cybox.mitre.org/extensions/Address#CIQAddress3.0-1").should == :extension
      type_for("http://stix.mitre.org/extensions/Address#CIQAddress3.0-1").should == :extension
      type_for("http://stix.mitre.org/extensions/Malware#MAEC4.1-1").should == :extension
    end

    it "should find components" do
      type_for("http://stix.mitre.org/Campaign-1").should == :component
      type_for("http://stix.mitre.org/TTP-1").should == :component
      type_for("http://stix.mitre.org/Indicator-2").should == :component
      type_for("http://stix.mitre.org/CourseOfAction-1").should == :component
    end

    it "should find data markings" do
      type_for("http://data-marking.mitre.org/Marking-1").should == :marking
    end

    it "should not recognize anything else" do
      type_for("http://google.com/schemas/4").should == nil
    end
  end

  context "#project" do
    it "should detect STIX" do
      project_for("http://stix.mitre.org/Campaign-1").should == :stix
      project_for("http://data-marking.mitre.org/Marking-1").should == :stix
    end

    it "should detect CybOX" do
      project_for("http://cybox.mitre.org/default_vocabularies-2").should == :cybox
    end

    it "should detect no known project" do
      project_for("http://maec.mitre.org/default_vocabularies-2").should == nil
    end
  end

  context "#name" do
    it "should find the name for core, common, and vocabs" do
      name_for("http://stix.mitre.org/stix-1").should == "STIX Core"
      name_for("http://cybox.mitre.org/cybox-2").should == "CybOX Core"

      name_for("http://stix.mitre.org/common-1").should == "STIX Common"
      name_for("http://cybox.mitre.org/common-2").should == "CybOX Common"

      name_for("http://stix.mitre.org/default_vocabularies-1").should == "STIX Vocabularies"
      name_for("http://cybox.mitre.org/default_vocabularies-2").should == "CybOX Vocabularies"
    end

    it "should find the name for objects" do
      @schema.stub(:xpath_name).and_return("Address_Object")
      name_for("http://cybox.mitre.org/objects#AddressObject-2").should == "Address Object"
    end

    it "should find the name for components" do
      @schema.stub(:xpath_name).and_return("STIX Campaign")
      name_for("http://stix.mitre.org/Campaign-1").should == "Campaign"

      @schema.stub(:xpath_name).and_return("STIX COA")
      name_for("http://stix.mitre.org/CourseOfAction-1").should == "Course of Action"
    end

    it "should find the name for extensions" do
      @schema.stub(:xpath_name).and_return("STIX Extension - Snort Test Mechanism Instance")
      name_for("http://stix.mitre.org/extensions/TestMechanism#Snort-1").should == "Snort Test Mechanism"
    end

    it "should find the name for extensions" do
      name_for("http://data-marking.mitre.org/Marking-1").should == "Data Markings"
    end

  end

  context "#schema_location" do
    it "should get schema location for core and common" do
      location_for("http://stix.mitre.org/stix-1", '1.1').should == "http://stix.mitre.org/XMLSchema/core/1.1/stix_core.xsd"
      location_for("http://cybox.mitre.org/cybox-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/core/2.1/cybox_core.xsd"

      location_for("http://stix.mitre.org/common-1", '1.1').should == "http://stix.mitre.org/XMLSchema/common/1.1/stix_common.xsd"
      location_for("http://cybox.mitre.org/common-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/common/2.1/cybox_common.xsd"
    end

    it "should get schema location for vocabularies" do
      location_for("http://stix.mitre.org/default_vocabularies-1", '1.1').should == "http://stix.mitre.org/XMLSchema/default_vocabularies/1.1/stix_default_vocabularies.xsd"
      location_for("http://cybox.mitre.org/default_vocabularies-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/default_vocabularies/2.1/cybox_default_vocabularies.xsd"
    end

    it "should get schema location for components" do
      @schema.stub(:title).and_return("Indicator")
      location_for("http://stix.mitre.org/Indicator-2", '2.1').should == "http://stix.mitre.org/XMLSchema/indicator/2.1/indicator.xsd"

      @schema.stub(:title).and_return("Threat Actor")
      location_for("http://stix.mitre.org/ThreatActor-2", '1.1').should == "http://stix.mitre.org/XMLSchema/threat_actor/1.1/threat_actor.xsd"

      @schema.stub(:title).and_return("Course of Action")
      location_for("http://stix.mitre.org/CourseOfAction-1", '1.1').should == "http://stix.mitre.org/XMLSchema/course_of_action/1.1/course_of_action.xsd"
    end

    it "should get schema location for objects" do
      location_for("http://cybox.mitre.org/objects#AddressObject-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/objects/Address/2.1/Address_Object.xsd"
      location_for("http://cybox.mitre.org/objects#WinNetworkShareObject-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/objects/Win_Network_Share/2.1/Win_Network_Share_Object.xsd"
      location_for("http://cybox.mitre.org/objects#FileObject-2", '2.1').should == "http://cybox.mitre.org/XMLSchema/objects/File/2.1/File_Object.xsd"
      location_for("http://cybox.mitre.org/objects#SocketAddressObject-1", '1.1').should == "http://cybox.mitre.org/XMLSchema/objects/Socket_Address/1.1/Socket_Address_Object.xsd"
    end

    it "should get schema location for extensions" do
      @schema.stub(:filename).and_return("snort_test_mechanism.xsd")
      location_for("http://stix.mitre.org/extensions/TestMechanism#Snort-1").should ==
                   "http://stix.mitre.org/XMLSchema/extensions/test_mechanism/snort/1.1/snort_test_mechanism.xsd"

      @schema.stub(:filename).and_return("capec_2.7_attack_pattern.xsd")
      location_for("http://stix.mitre.org/extensions/AP#CAPEC2.7-1").should ==
                   "http://stix.mitre.org/XMLSchema/extensions/attack_pattern/capec_2.7/1.1/capec_2.7_attack_pattern.xsd"

      @schema.stub(:filename).and_return("terms_of_use_marking.xsd")
      location_for("http://data-marking.mitre.org/extensions/MarkingStructure#Terms_Of_Use-1").should ==
                   "http://stix.mitre.org/XMLSchema/extensions/marking/terms_of_use/1.1/terms_of_use_marking.xsd"

      @schema.stub(:filename).and_return("generic_structured_coa.xsd")
      location_for("http://stix.mitre.org/extensions/StructuredCOA#Generic-1").should ==
                   "http://stix.mitre.org/XMLSchema/extensions/structured_coa/generic/1.1/generic_structured_coa.xsd"
    end

    it "should get schema location for markings" do
      location_for("http://data-marking.mitre.org/Marking-1").should == "http://stix.mitre.org/XMLSchema/data_marking/1.1/data_marking.xsd"
    end
  end

  it "should get the xpath schema name" do
    Schema.new('config/schemas/stix/campaign.xsd').xpath_name.should == 'STIX Campaign'
    Schema.new('config/schemas/stix/cybox/objects/Address_Object.xsd').xpath_name.should == 'Address_Object'
  end
end