require "QuickBaseClient"

# print the list of QuickBase formula functions in JSON format:

qbc=QuickBase::Client.new(ENV["quickbase_username"],ENV["quickbase_password"])
puts qbc.getAllValuesForFieldsAsPrettyJSON("6ewwzuuj",["Function Name"])
