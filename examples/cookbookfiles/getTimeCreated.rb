
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc = QuickBase::Client.new("username","password")
qbc.getDBInfo("8emtadvk")
createdTimeString = qbc.formatFieldValue(qbc.createdTime,"timestamp")
puts "The QuickBase Community Forum was created #{createdTimeString} (#{qbc.createdTime})."
