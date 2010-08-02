
require 'QuickBaseClient'

#sign into a QuickBase application using your user name and password
qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )

# if your application is a multi-table application, switch 
# to the right table
qbc.lookupChdbid( "Imported Excel data" )

# delete all the records in the "Imported Excel data" table then
# import new data from an Excel file. The field names must be at the top of the file.
# 'h' is the letter of the last column to import.
# Note: any commas (',') in the data are converted to semi-colons (';').
# Uncomment the following line if you want to make your QuickBase table match the contents of your Excel file.

#qbc._purgeRecords

qbc._importFromExcel( "ImportedExcelData.xls", 'h' )

#sign out of QuickBase
qbc.signOut
