require 'QuickBaseClient'
qbc = QuickBase::Client.new( "my_username", "my_password", "My QuickBase Database" )
qbc.makeSVFile( "MyCSVFile.csv" )
qbc.signOut
