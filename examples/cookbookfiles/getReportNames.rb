require 'QuickBaseClient'

qbc = QuickBase::Client.new

# list the reports from the Formula Functions Reference table in the QuickBase Support Center
puts qbc.getReportNames("6ewwzuuj")

=begin

The above code prints the list below:-

All Functions
All Functions and Operators
Boolean Functions
Formula Export View
gsa_formula functions ref
List All
List Changes
Number Functions
Operators - Binary
Operators - Unary
Text Functions
Time and Date Functions

=end
