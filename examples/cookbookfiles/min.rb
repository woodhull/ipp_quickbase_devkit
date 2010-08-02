
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.iterateRecords("bcct3jb3b",["number"]){|record|
   puts "number: #{record['number']}" 
}

min = qbc.min("bcct3jb3b",["number"])
puts "min: #{min['number']}" 

=begin

number: 62
number: 21
number: 76
number: 13
number: 34
number: 2
number: 66
number: 2
number: 3
min: 2.0

=end
