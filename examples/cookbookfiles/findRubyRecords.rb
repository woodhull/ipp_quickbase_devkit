
require 'QuickBaseClient'

# change "username" "password" to your QuickBase username and password
qbc =  QuickBase::Client.new("username","password")

communityForumRecords = qbc.getAllValuesForFields("8emtadvk",["Subject","Message"],"{'0'.CT.'ruby'}",nil,nil,"6.10")

puts "\n --- QuickBase Community Forum Records containing the word 'ruby' ---\n\n"

numRecords = communityForumRecords["Subject"].length
(0..(numRecords-1)).each{|index|
   print "\nSubject: "
   print communityForumRecords["Subject"][index]
   puts "\nMessage:"
   puts communityForumRecords["Message"][index].gsub!("<BR/>","\n")
}
