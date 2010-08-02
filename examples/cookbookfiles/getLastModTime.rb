
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc = QuickBase::Client.new("username","password")
qbc.getDBInfo("8emtadvk")
lastModifiedTimeString = qbc.formatFieldValue(qbc.lastModifiedTime,"timestamp")
puts "The last thing modified in the QuickBase Community Forum was at #{lastModifiedTimeString} (#{qbc.lastModifiedTime})."
