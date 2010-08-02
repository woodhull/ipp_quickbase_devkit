require 'QuickBaseClient'

qbc = QuickBase::Client.new

# List the Pages from the QuickBase Support Center
qbc.iterateDBPages("9kaw8phg"){|page|
  puts "Page: #{page['name']}, Type: #{page['type']}, ID: #{page['id']}\n" 
}
