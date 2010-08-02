
require 'QuickBaseClient'

#
# This script reads the list of records from a Documents table and a Doctors table
# And creates mssing records in a Progress table for all the combinations of Doctors and Documents
#

# Check the command line for username, password ---------------------
if ARGV.length == 1 and ARGV[0] == "?"
   puts "\n\nUsage: ruby makerecs.rb username password\n\nThis program adds records to the Progress table\nfor each record added to the Documents table.\n\n"
   exit 1 
elsif ARGV.length > 1
   username = ARGV[0]
   password = ARGV[1]
else
   puts "\nPlease enter your username and password, e.g.\n\n\truby makerecs.rb fred amliw\n\n"
   exit 1 
end

documentsDBID = "xxxxxxxxx" # fictitious!   please use a valid table dbid
doctorsDBID = "yyyyyyyyy" # fictitious!   please use a valid table dbid
progressDBID = "zzzzzzzzz" # fictitious!   please use a valid table dbid

# Signin  to QuickBase ----------------------------------------------
qbc = QuickBase::Client.new( username, password )

# Collect the record IDs from the Documents table -------------------
documentRids = qbc.getAllRecordIDs( documentsDBID ) #Documents table
puts "Document IDs = #{documentRids.join( ',' )}"

# Collect the record IDs from the Doctors table ---------------------
doctorRids = qbc.getAllRecordIDs( doctorsDBID ) #Doctors table
puts "Doctor IDs = #{doctorRids.join( ',' )}"

# Collect the Document and Doctor IDs from the Progress table -------
progressIDs = qbc.getAllValuesForFields( progressDBID, [ "DoctorID", "DocumentID" ] ) # Progress table

puts "Progress Document IDs = #{progressIDs["DocumentID"].join(',')}"
puts "Progress Doctor IDs = #{progressIDs["DoctorID"].join(',')}"

# Collect the Documents that are missing from the Progress table ----------------
missingProgressDocuments = Array.new
documentRids.each{ |documentRid| 
        if not progressIDs["DocumentID"].include?( documentRid )
           missingProgressDocuments << documentRid
        end
   }

puts "Missing Progress Document IDs = #{missingProgressDocuments.join(',')}"

# For each missing Document, add a record to the Progress table for each Doctor -
missingProgressDocuments.each{ |documentRid|
   doctorRids.each{ |doctorRid|
      qbc.clearFieldValuePairList
      qbc.addFieldValuePair( "DocumentID", nil, nil, documentRid )
      fieldValueList = qbc.addFieldValuePair( "DoctorID", nil, nil, doctorRid )
      qbc.addRecord( progressDBID, fieldValueList )
   }
}

# Signout from QuickBase --------------------------------------------
qbc.signOut

