
require 'QuickBaseClient'
require 'Date'

# login and connect to the "Email Outbox" application
qbc = QuickBase::Client.new("username","password","Email Outbox")

# find the "Messages" table in the "Email Outbox" application
outboxMessagesTable = qbc.lookupChdbid("Messages")

today = Date.today
today = today.strftime("%m-%d-%Y")

# for every record that was created today, change the "from" field to "fred@bedrock.com" and the "to" field to "wilma@bedrock.com"
qbc.editRecords(outboxMessagesTable,{"from"=>"fred@bedrock.com","to"=>"wilma@bedrock.com"},"{'1'.EX.'#{today}'}")
