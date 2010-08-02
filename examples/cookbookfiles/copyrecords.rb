require 'QuickBaseClient'
require 'Date'

if ARGV.length < 4
   puts "\n Usage: ruby copyrecords.rb <username> <password> <sourceTableDBID> <targetTableDBID>\n"
   puts "\n e.g. ruby copyrecords.rb myusername mypassword xxxxxxxxx yyyyyyyyy\n."
   puts "\n Adds copies of records from a main table to a history table."
   puts "\n This script assumes the field names match between the two tables.\n"
   exit
end

qbc = QuickBase::Client.new( ARGV[0], ARGV[1] )

#Uncomment the following line to see the data being sent to QuickBase and returned from QuickBase
#qbc.printRequestsAndResponses = true 

#fieldNames is the list of fields values you want to copy
#Change the list to match your real field names.

fieldNames = Array.new
fieldNames = [ "Record ID#", "Date Updated", "Title", "Description", "MutipleChoiceField" ]

puts "Adding copies of all source table records to target table"

#fieldValues is a hash of arrays of field values from all records in the source table
qbc.getSchema( ARGV[2] )
fieldValues = qbc.getAllValuesForFields( ARGV[2], fieldNames )
numRecs = fieldValues[ "Record ID#" ].length

#for each record (i) retrieved from the source table...
(0..numRecs.to_i-1).each{ |i|
   
   #clear previously uploaded field values
   qbc.clearFieldValuePairList
   
   #loop through the list of field values for record i
   fieldValues.each { |fieldName,valueArray|
   
       # get the value of fieldName in record i
       value = valueArray[i]
       
       # copy the field name - it will need to be changed for some fields
       targetFieldName = fieldName.dup
       
       # date fields must be converted from the numeric version to a format that can be sent back to QuickBase
       value = qbc.formatDate( value, nil, true ) if targetFieldName == "Date Updated"
       
       # put the source table's Record ID# in a different field in the target table
       # (you could do this for any field that has a different name in the target table)
       targetFieldName = "Source Record ID #" if targetFieldName == "Record ID#"
       
       # the values of multiple choice fields must be in the list of available choices
       if targetFieldName == "MutipleChoiceField"  
          qbc._fieldNameAddChoices( targetFieldName, value ) 
       end
       
       # add the field value to the list of fields to be uploaded to the target table
       qbc.addFieldValuePair( targetFieldName, nil, nil,  value ) 
   }
   
   puts "Adding record #{i} of #{numRecs.to_i-1}"
   qbc.addRecord( ARGV[3], qbc.fvlist )
   
   # print any error message from QuickBase, if there was one
   if !qbc.requestSucceeded
     qbc.printLastError
   end
   
}

# signout of QuickBase
qbc.signOut

