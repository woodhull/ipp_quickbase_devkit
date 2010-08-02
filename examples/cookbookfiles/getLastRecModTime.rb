
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc = QuickBase::Client.new("username","password")
qbc.getDBInfo("8emtadvk")
lastRecModTimeString = qbc.formatFieldValue(qbc.lastRecModTime,"timestamp")
puts "A record was last modified in the QuickBase Community Forum at #{lastRecModTimeString} (#{qbc.lastRecModTime})."
