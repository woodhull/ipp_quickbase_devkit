
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc = QuickBase::Client.new("username","password")
puts "Logging XML requests and responses in file logfile.csv."
qbc.logToFile( "logfile.csv" )
qbc.getSchema("8emtadvk") #QuickBase Community Forum database
