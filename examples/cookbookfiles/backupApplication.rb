require 'QuickBaseClient'

qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )

# "true" at the end means copy all the data, not just the structure of the database
qbc.cloneDatabase( qbc.dbid, "my_application_backup", "backup of my_application", true )

qbc.signOut
