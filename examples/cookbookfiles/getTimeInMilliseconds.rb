require 'QuickBaseMisc'

puts "\n\nThe time now in milliseconds is #{QuickBase::Misc.time_in_milliseconds}."
puts "\nThe time in milliseconds at the beginning of today was #{QuickBase::Misc.time_in_milliseconds(Date.today)}."
puts "\nThe time in milliseconds at this time tomorrow will be #{QuickBase::Misc.time_in_milliseconds(DateTime.now + 1)}."
