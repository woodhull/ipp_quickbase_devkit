

require 'QuickBaseClient'

qbc = QuickBase::Client.new

puts "\n\nDate/time information about the QuickBase Community Forum:\n\n"

qbc.getAppDTMInfo("bbqm84dzy")

puts "Time of request                : #{qbc.formatFieldValue(qbc.requestTime.text,'timestamp')}"
puts "Time next request allowed      : #{qbc.formatFieldValue(qbc.requestNextAllowedTime.text,'timestamp')}"
puts "Time application last modified : #{qbc.formatFieldValue(qbc.lastModifiedTime,'timestamp')}"
puts "Time any record last modified  : #{qbc.formatFieldValue(qbc.lastRecModTime,'timestamp')}"

   
=begin

Output of the above script:

Date/time information about the QuickBase Community Forum:

Time of request                : 05-03-2009 03:52 PM
Time next request allowed      : 05-03-2009 03:52 PM
Time application last modified : 03-26-2009 01:55 PM
Time any record last modified  : 05-02-2009 10:10 AM

=end

