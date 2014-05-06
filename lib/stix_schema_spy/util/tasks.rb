require 'fileutils'
require 'nokogiri'

namespace :stix_schema_spy do

  desc "Convert the STIX source schemas into compiled schemas useful for validation. Mainly used to update the schemas within stix_schema_spy itself."
  task :generate_schemas, [:input_dir, :output_dir] do |task, args|
    schema_dir = args[:input_dir]
    output_dir = File.expand_path(args[:output_dir])
    stix_dir = output_dir + "/stix"

    raise "Please specify the schemas directory and the output directory" if schema_dir.nil? || output_dir.nil?

    import_chains = Hash.new([])
    namespace_map = {}

    # Create the output directory
    FileUtils.mkdir_p(stix_dir)

    # Collect each of the necessary schemas
    Dir.chdir(schema_dir) do
      namespace_map = Dir.glob('**/*.xsd').each_with_object({}) do |schema_location, coll|
        next if schema_location =~ /uber_schema/
        puts "Processing #{schema_location}"
        filename = schema_location.split('/').last

        File.open(schema_location, 'r:bom|utf-8') do |file| # This discards the UTF BOM, which will choke libxml/nokogiri

          # Get the schema text
          schema = file.read
          
          # Parse the document and grab the namespace
          src = Nokogiri::XML::Document.parse(schema, nil, nil, Nokogiri::XML::ParseOptions::PEDANTIC)
          namespace = src.root.attributes['targetNamespace'].value

          # If there are any includes, we need to start tracking them
          src.root.xpath('xs:include', {'xs' => 'http://www.w3.org/2001/XMLSchema'}).each do |import|
            import_chains[namespace] << import.attributes['schemaLocation'].value.split('/').last
          end

          # Add the schema if it's the top level of the include chain
          coll[namespace] = schema_location unless import_chains[namespace].include?(filename) # Set this namespace's parent to the current schema unless any other includes point to it

          # Write the schema out to the target directory
          directory = schema_location.split('/')[0..-2].join('/')
          Dir.chdir(stix_dir) {
            FileUtils.mkdir_p(directory) if directory.length > 0
            File.open(schema_location, "w") {|f| f.write(schema)}
          }
        end            
      end
    end

    # Then build them into a series of import statements
    doc = Nokogiri::XML::Builder.new  do |xml|
      xml.schema('xmlns' => 'http://www.w3.org/2001/XMLSchema') do |root|
        namespace_map.each do |namespace, schema_location|
          root.import('namespace' => namespace, 'schemaLocation' => "#{schema_location}")
        end
      end
    end

    # Write the schema
    Dir.chdir(output_dir) {
      File.open("uber_schema.xsd", "w") {|f| f.write(doc.to_xml)}  
    }
    
  end

end