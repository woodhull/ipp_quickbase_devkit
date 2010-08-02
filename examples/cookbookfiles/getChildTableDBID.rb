
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")
qbc.printRequestsAndResponses=true 
applicationDBID = qbc.findDBByname("QuickBase API Cookbook v2")
qbc.getSchema(applicationDBID)
childDBID = qbc.lookupChdbid("Ingredients")
puts "The dbid of the 'Ingredients' table in the QuickBase API Cookbook v2 application is #{childDBID}"

