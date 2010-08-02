require 'QuickBaseClient'

puts "\nThe QuickBase Support Center has these child tables:\n\n"
puts QuickBase::Client.new.getTableIDs("9kaw8phg").join("\n")


