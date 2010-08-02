require 'QuickBaseClient'

puts "\n\nThe field IDs for the QuickBase Community Forum are : #{QuickBase::Client.new.getFieldIDs("8emtadvk").join(",")}\n\n"
 
 
 