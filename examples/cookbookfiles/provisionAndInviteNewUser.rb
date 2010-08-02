
require 'QuickBaseClient'

# Add a new user to QuickBase and email the user an invitation to an application

qbc = QuickBase::Client.new("username","password","My Fantastic Application")

# Assume "11" is the id of the Participant role in "My Fantastic Application"

qbc._provisionUser("11", "fred_flintstone@internet.com", "fred", "flintstone")

qbc._sendInvitation(qbc.userid)

