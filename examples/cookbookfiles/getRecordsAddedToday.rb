
require 'QuickBaseClient'
require 'Date'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

today = Date.today
today = today.strftime("%m-%d-%Y")
communityForumRecords = qbc.getAllValuesForFields("8emtadvk",["Subject","Message"],"{'1'.EX.'#{today}'}",nil,nil,"6.10")

puts "\n --- QuickBase Community Forum Records added today ---\n\n"

numRecords = communityForumRecords["Subject"].length
(0..(numRecords-1)).each{|index|
   print "\nSubject: "
   print communityForumRecords["Subject"][index]
   puts "\nMessage:"
   puts communityForumRecords["Message"][index].gsub!("<BR/>","\n")
}
