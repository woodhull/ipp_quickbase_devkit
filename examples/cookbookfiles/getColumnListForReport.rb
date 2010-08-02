require 'QuickBaseClient'

qbc = QuickBase::Client.new
qbc.getSchema("8emtadvk")
puts "Columns for QuickBase Community Forum 'List all' report: #{qbc.getColumnListForQuery(nil,'List All')}"
puts "Columns for QuickBase Community Forum 'List all' report: #{qbc.getColumnListForQuery("1",nil)}"
