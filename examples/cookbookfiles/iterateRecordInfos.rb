require 'QuickBaseClient'

puts "\n\nQuickBase Formula Functions Reference:\n\n"

QuickBase::Client.new.iterateRecordInfos("6ewwzuuj"){|ri|  
  puts "------------------------------"
  ri.each{|field,value| puts "#{field}: #{value}\n"}
}
