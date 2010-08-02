

require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password","My Application")

qbc._userRoles() { |user|
  qbc.printChildElements( user )
}

=begin

Approximate output of above script:

user (id=3453444.csw ):
 name  = Fred Flintstone
 lastAccess  = 1241207132457
 firstName  = Fred
 lastName  = Flintstone
 roles :
  role (id=18 ):
   name  = Participant with Modify Own
   access (id=3 ) = Basic Access
user (id=345434444.bpw5 ):
 name  = Wilma Flintstone
 lastAccess  = 1240232570603
 firstName  = Wilma
 lastName  = Flintstone
 roles :
  role (id=18 ):
   name  = Participant with Modify Own
   access (id=3 ) = Basic Access
user (id=24343444.bh ):
 name  = Top Sales
 lastAccess  = 1236700941307
 firstName  = Top
 lastName  = Sales
 roles :
  role (id=18 ):
   name  = Participant with Modify Own
   access (id=3 ) = Basic Access
user (id=111.ckbs ):
 name  = Anonymous
 roles :
  role (id=11 ):
   name  = Participant
   access (id=3 ) = Basic Access
=end

