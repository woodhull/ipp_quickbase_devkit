require 'QuickBaseClient'

qbc = QuickBase::Client.new
puts "There are #{qbc.getNumTables("bbtt9cjr6")} tables in the QuickBase Application Library."
