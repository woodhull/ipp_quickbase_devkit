require 'QuickBaseClient'

qbc = QuickBase::Client.new
qbc.getSchema("8emtadvk")
puts "Sort fields for QuickBase Community Forum 'List Changes' report: #{qbc.getSortListForQuery(nil,'List Changes')}"
puts "Sort fields for QuickBase Community Forum 'List Changes' report: #{qbc.getSortListForQuery('2',nil)}"
