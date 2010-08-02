
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# Attempt to change Name to Fred in record 7
# If there is no record 7, add a new record and set the Name to Fred.
qbc.addFieldValuePair("Name",nil,nil,"Fred")
qbc.addOrEditRecord("dbiddbid",qbc.fvlist,"7")

