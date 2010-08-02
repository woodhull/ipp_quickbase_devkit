require 'QuickBaseObjects'

qbob = QuickBase::Objects::Builder.new("username","password")
  
myApplication = qbob.application("My Application")
  
puts "\n\nApplication name:\n"
puts myApplication.name

puts "\n\nApplication roles:\n"
myApplication.roles.each_value{|role|puts "name: #{role.name}, id: #{role.id}, access: #{role.access}"}

puts "\n\nApplication users:\n"
myApplication.users.each_value{|user|puts "id: #{user.id}"}

puts "\n\nApplication variables:\n"
myApplication.variables.each_value{|variable|puts "#{variable.name}: #{variable.value}"}

puts "\n\nValue of application variable 'TestVariable':\n"
puts myApplication.vTestVariable

puts "\n\nSet the value of application variable 'TestVariable':\n"
myApplication.vTestVariable="New value for test variable"

puts "\n\nApplication pages:\n"
myApplication.pages.each_value{|page|puts page.name}

puts "\n\nDefault application page:\n"
puts myApplication.pDefault_Dashboard.name
  
puts "\n\nTables from My Application:\n"
myApplication.tables.each_value{|table|puts table.name}
  
puts "\n\nQueries from the Contacts table:\n"
myApplication.tContacts.queries.each_value{|query|puts query.name}

puts "\n\nProperties of the List All query from the Contacts table:\n"
myApplication.tContacts.qList_All.properties.each_pair{|key,value|puts "#{key}: #{value}" }

puts "\n\nNames from the List All query from the Contacts table:\n"
records = myApplication.tContacts.qList_All.run 
records.each{|record| puts record.fName}

puts "\n\nColumns of the List All query from the Contacts table:\n"
puts myApplication.tContacts.qList_All.qyclst
  
puts "\n\nFields from the Contacts table:\n"
myApplication.tContacts.fields.each_value{|field|puts field.name}
  
puts "\n\nField ID of the Phone field in the Contacts table:\n"
puts myApplication.tContacts.fPhone.id

puts "\n\nName of field 7 from the Contacts table:\n"
puts myApplication.tContacts.fields["7"].name

