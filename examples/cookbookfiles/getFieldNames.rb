
require 'QuickBaseClient'

puts "Fields from the QuickBase Community Forum: "
qbc = QuickBase::Client.new
puts qbc.getFieldNames("8emtadvk")
