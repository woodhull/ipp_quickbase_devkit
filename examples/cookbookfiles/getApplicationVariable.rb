require 'QuickBaseClient'
qbc = QuickBase::Client.new("username","password","My Application Name")
puts qbc.getApplicationVariable("var")
p qbc.getApplicationVariable

