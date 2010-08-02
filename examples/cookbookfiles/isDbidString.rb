
require 'QuickBaseMisc'

print "\n\nEnter a string: "
string = gets.chop

puts "\n\n'#{string}' is #{QuickBase::Misc.isDbidString?(string) ? '' : 'not'} a valid QuickBase table id string.\n\n"

