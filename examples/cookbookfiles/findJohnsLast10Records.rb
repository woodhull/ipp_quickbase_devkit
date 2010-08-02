
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

communityForumRecords = qbc.getAllValuesForFields("8emtadvk",["Subject","Message"],"{'4'.CT.', John'}",nil,nil,"6.10",nil,"structured","num-10")

puts "\n --- Ten most recent QuickBase Community Forum Records owned by ', John' ---\n\n"

numRecords = communityForumRecords["Subject"].length
(0..(numRecords-1)).each{|index|
   print "\n#{index+1})\nSubject: "
   print communityForumRecords["Subject"][index]
   puts "\nMessage:"
   puts communityForumRecords["Message"][index].gsub!("<BR/>","\n")
}
