
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.applyPercentToRecords("bcc9qcnxw","number","percent")

numberTotal = qbc.sum("bcc9qcnxw",["number"])
puts "number total: #{numberTotal['number']}"

qbc.iterateRecords("bcc9qcnxw",["number","percent"]){|record|
   puts "number: #{record['number']}, percent: #{record['percent'].to_f*100}"
}

percentTotal = qbc.sum("bcc9qcnxw",["percent"])
puts "percent total: #{percentTotal['percent'].to_f*100}"

=begin

Sample output of above script:-

number total: 124.0
number: 20, percent: 16.12903225806
number: 36, percent: 29.03225806452
number: 56, percent: 45.16129032258
number: 12, percent: 9.67741935484
percent total: 100.0

=end
