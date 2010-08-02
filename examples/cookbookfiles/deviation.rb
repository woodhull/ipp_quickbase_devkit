
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.applyDeviationToRecords("bcc9qcnxw","number","deviation")

numberAverage = qbc.average("bcc9qcnxw",["number"])
puts "number average: #{numberAverage['number']}"

qbc.iterateRecords("bcc9qcnxw",["number","deviation"]){|record|
   puts "number: #{record['number']}, deviation: #{record['deviation']}"
}

=begin

Sample output of above script:-

number average: 31.0
number: 20, deviation: 11
number: 36, deviation: 5
number: 56, deviation: 25
number: 12, deviation: 19

=end
