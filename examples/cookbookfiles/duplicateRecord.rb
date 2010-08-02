require 'QuickBaseClient'

qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )

# make 6 copies of record 1
qbc.copyRecord( "1", 6 )

qbc.signOut