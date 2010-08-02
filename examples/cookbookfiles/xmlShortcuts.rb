
require 'QuickbaseClient'

qbc = QuickBase::Client.new

qbc.getSchema("bbqm84dzy")
puts "\n\nSchema information for QuickBase Community Forum application:\n\n"

puts "Application dbid: #{qbc.xml_app_id}"
puts "Application description: #{qbc.xml_desc}"
puts "XML for list of child tables: #{qbc.xml_chdbids}"
puts "Last child table dbid: #{qbc.xml_chdbid}"
puts "Application variables: #{qbc.xml_variables}"

qbc.getSchema("8emtadvk")
puts "\n\nSchema information for QuickBase Community Forum Messages table:\n\n"

puts "Table name: #{qbc.xml_table.elements['name'].text}"
puts "Field 1 name: #{qbc.xml_field('1').label}"
puts "Field 2 name: #{qbc.xml_field('id','2').label}"
puts "Field 3 reuired?: #{qbc.xml_field('3').required == 1}"
puts "Query 2 criteria: #{qbc.xml_query('2').qycrit}"
puts "XML for Query 1: #{qbc.xml_query('1')}"
puts "Name for Query 1: #{qbc.xml_query('1').qyname}"
puts "Next Record #ID will be: #{qbc.xml_next_record_id}"

qbc.getRecordInfo("8emtadvk","24105")
puts "\n\nInfo from Record 24105:\n\n"

puts "Number of fields in record: #{qbc.xml_num_fields}"
puts "XML of last field: #{qbc.xml_field}"
puts "ID of last field: #{qbc.xml_field.fid}"
puts "Name of last field: #{qbc.xml_field.elements['name'].text}"
