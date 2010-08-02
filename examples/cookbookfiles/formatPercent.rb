
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

# read and format the "percent" field from all the records in a table
qbc.iterateRecords("dbiddbid",["percent"]){|rec|
  formattedValue  = qbc.formatPercent(rec['percent'])
  puts "Raw percent value from QuickBase: #{rec['percent']}, Formatted value: #{formattedValue}"
}

=begin

Sample output from this script:

Raw percent value from QuickBase: 0.005, Formatted value: 0.5
Raw percent value from QuickBase: 0.12, Formatted value: 12
Raw percent value from QuickBase: 0.9999, Formatted value: 99.99
Raw percent value from QuickBase: 0.5, Formatted value: 50
Raw percent value from QuickBase: 0.13, Formatted value: 13
Raw percent value from QuickBase: 0.33123, Formatted value: 33.12

=end
