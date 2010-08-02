
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

# read and format the "duration" field from all the records in a table
qbc.iterateRecords("dbiddbid",["duration"]){|rec|
  rawValue = rec['duration']
  days = qbc.formatDuration(rawValue.dup,"days")
  hours  = qbc.formatDuration(rawValue.dup,"hours")
  minutes  = qbc.formatDuration(rawValue.dup,"minutes")
  printf("Raw value: %-15s Days: %-10s Hours: %-10s Minutes: %-10s\n", rec['duration'], days, hours, minutes)
}

=begin

Sample output from this script:

Raw value: 172800000       Days: 2          Hours: 48         Minutes: 2880
Raw value: 285120000       Days: 3          Hours: 79         Minutes: 4752
Raw value: 2160000000      Days: 25         Hours: 600        Minutes: 36000
Raw value: 10658304000     Days: 123        Hours: 2960       Minutes: 177638
Raw value: 37152000        Days: 0          Hours: 10         Minutes: 619
Raw value: 86400000        Days: 1          Hours: 24         Minutes: 1440

=end
