
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")
createdFieldValue = qbc.getAllValuesForFields("8emtadvk",["Created"],"{'3'.EX.'24105'}")
createdFieldValue = createdFieldValue["Created"][0]
formattedCreatedFieldValue  = qbc.formatDate(createdFieldValue)
puts "Message 24105 in the QuickBase Community Forum was created on #{formattedCreatedFieldValue} (#{createdFieldValue})."

