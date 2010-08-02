
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# run pre-defined Import #3 into table bcdcajmrf

qbc.runImport("bcdcajmrf","3")

