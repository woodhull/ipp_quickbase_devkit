
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# get Fred's QuickBase user info
qbc.getUserInfo("fred_flintstone@internet.com")

fredsUserID = qbc.userid.dup

# Assume "10" is the id of the Viewer role in the application with the "bbqm84dzy" id
qbc.addUserToRole( "bbqm84dzy", fredsUserID, "10" )

# Assume "11" is the id of the Participant role in the application with the "bbqm84dzy" id
qbc.changeUserRole( "bbqm84dzy", fredsUserID, "10", "11" )

# Remove Fred from the Participant Role
qbc.removeUserFromRole( "bbqm84dzy", fredsUserID, "11" )



