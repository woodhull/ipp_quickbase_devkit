
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc = QuickBase::Client.new("username","password")
qbc.printRequestsAndResponses = true
puts "Show the XML request and response while getting info about the QuickBase Community Forum database."
qbc.getDBInfo("8emtadvk")
