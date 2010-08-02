
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

cookbookRecords = qbc.getAllValuesForFields("bb2mad4sr",["Title","Keywords"])

puts "\n --- QuickBase API Cookbook v2 ---\n\n"

numRecords = cookbookRecords["Title"].length
(0..(numRecords-1)).each{|index|
   print "Title: "
   print cookbookRecords["Title"][index]
   print "  (Keywords: "
   print cookbookRecords["Keywords"][index]
   puts ")"
}
