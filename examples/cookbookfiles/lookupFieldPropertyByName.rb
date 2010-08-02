require 'QuickBaseClient'

qbc = QuickBase::Client.new

qbc.getSchema("8emtadvk")
showTimeInDateModified = qbc.lookupFieldPropertyByName("Date Modified","display_time") == "1" ? "is" : "is not"

puts "\nFor the Date Modified field in the QuickBase Community Forum, the time of day #{showTimeInDateModified} displayed.\n"

puts "\nThe field properties you can lookup are: \n\n"
puts qbc.validFieldProperties.join("\n")

=begin

The above code prints -


For the Date Modified field in the QuickBase Community Forum, the time of day is displayed.

The field properties you can lookup are:

allowHTML
allow_new_choices
appears_by_default
append_only
blank_is_zero
bold
carrychoices
comma_start
cover_text
decimal_places
default_kind
default_today
display_dow
display_month
display_relative
display_time
display_today
display_user
display_zone
does_average
does_total
doesdatacopy
exact
find_enabled
foreignkey
label
nowrap
num_lines
required
sort_as_given
unique
use_new_window
target_dbid
target_dbname
target_fieldname
target_fid
source_fieldname
source_fid

=end

