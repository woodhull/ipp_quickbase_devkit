require 'QuickBaseClient'

#loop { 

   qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )
   qbc.lookupChdbid( "my_table" ) 
   qbc._purgeRecords
   qbc.signOut
   
#   qbc = nil
#   sleep(60*60)
#}

# to empty a table automatically every hour, remove 
# the '#' from the beginning of the lines above  
