
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

qbc.doQuery("6ewwzuuj")

puts "\n --- QuickBase Formula Functions Reference ---\n\n"

recordNumber = 1
qbc.eachRecord(qbc.records){|record|
   puts "\n --- Record #{recordNumber} ---"
   recordNumber += 1
   qbc.eachField(record){|field|
      print qbc.lookupFieldNameFromID(field.attributes["id"])
      print ": "
      if field.has_text?
         text =  field.text.dup
         text.gsub!("<BR/>","\n") if text.include?("<BR/>")
         puts text 
      end
   }
}
