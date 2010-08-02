require 'QuickBaseClient'

#sign into your application using your user name and password
qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )

# If your application is a multi-table application, switch to the correct target table using lookupChdbid
qbc.lookupChdbid( "Imported data" )

# delete all the records in the "Imported data" table then
# import new data from a CSV file. The field names must be at the top of the file.

# Uncomment the following line to make your QuickBase table
# have the same contents as your CSV file.
#qbc._purgeRecords

# (change 'ImportedData.csv' to a real file name)
qbc.importCSVFile( "ImportedData.csv" )

#sign out of QuickBase
qbc.signOut
