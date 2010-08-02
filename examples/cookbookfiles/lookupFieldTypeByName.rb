
require 'QuickBaseClient'

qbc = QuickBase::Client.new

qbc.getSchema("8emtadvk") #Messages table in QuickBase Community Forum

puts qbc.lookupFieldTypeByName("Thread")

# the line above prints "url" on the screen
