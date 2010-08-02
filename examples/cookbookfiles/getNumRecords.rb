
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")
numRecords = qbc.getNumRecords("8emtadvk")
puts "There are #{numRecords} in the QuickBase Community Forum database"

