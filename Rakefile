require "bundler/gem_tasks"
require 'nokogiri'

namespace :stix_schema_spy do

  desc "Generate the uber-schema that can be used to validate against a single file"
  task :generate_uber_schema do

    import_chains = Hash.new([])
    namespace_map = {}

    # Collect each of the necessary schemas
    Dir.chdir('config/schemas') do
      namespace_map = Dir.glob('**/*.xsd').each_with_object({}) do |schema_location, coll|
        puts "Processing #{schema_location}"
        filename = schema_location.split('/').last

        File.open(schema_location, 'r:bom|utf-8') do |file| # This discards the UTF BOM, which will choke libxml/nokogiri
          
          # Parse the document and grab the namespace
          src = Nokogiri::XML::Document.parse(file.read, nil, nil, Nokogiri::XML::ParseOptions::PEDANTIC)
          namespace = src.root.attributes['targetNamespace'].value

          # If there are any includes, we need to start tracking them
          src.root.xpath('xs:include', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).each do |import|
            import_chains[namespace] << import.attributes['schemaLocation'].value.split('/').last
          end

          coll[namespace] = schema_location unless import_chains[namespace].include?(filename) # Set this namespace's parent to the current schema unless any other includes point to it
        end            
      end
    end

    # Then build them into a series of import statements
    doc = Nokogiri::XML::Builder.new  do |xml|
      xml.schema('xmlns' => 'http://www.w3.org/2001/XMLSchema') do |root|
        namespace_map.each do |namespace, schema_location|
          root.import('namespace' => namespace, 'schemaLocation' => "schemas/#{schema_location}")
        end
      end
    end

    # Write the schema
    File.open("config/uber_schema.xsd", "w") {|f| f.write(doc.to_xml)}
  end
end