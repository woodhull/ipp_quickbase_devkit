
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

# read and format the "currency" field from all the records in a table
qbc.iterateRecords("dbiddbid",["currency"]){|rec|
  formattedValue  = qbc.formatCurrency(rec['currency'],{"currencySymbol" => "$"})
  puts "Raw currency value from QuickBase: #{rec['currency']}, Formatted value: #{formattedValue}"
}

=begin

Sample output from this script:

Raw currency value from QuickBase: 7.33, Formatted value: $7.33
Raw currency value from QuickBase: 0.33, Formatted value: $0.33
Raw currency value from QuickBase: 1.01, Formatted value: $1.01
Raw currency value from QuickBase: 1888888.00, Formatted value: $1888888.00
Raw currency value from QuickBase: 1111.1111, Formatted value: $1111.1111
Raw currency value from QuickBase: 23.23, Formatted value: $23.23

=end
