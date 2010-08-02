require 'QuickBaseClient'

qbc = QuickBase::Client.new

puts "The name of the table for dbid 'bbqm84dzy' is '#{qbc.getTableName('bbqm84dzy')}'."

# The above code prints  - 
# The name of the table for dbid 'bbqm84dzy' is 'QuickBase Community Forum'.
