
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.iterateRecords("bcct3jb3b",["number"]){|record|
   puts "number: #{record['number']}" 
}

max = qbc.max("bcct3jb3b",["number"])
puts "max: #{max['number']}" 

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
max: 76.0

=end
