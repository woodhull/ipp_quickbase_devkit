
require 'QuickBaseClient'

qbc = QuickBase::Client.new
puts " ---------- Records from the QuickBase Community Forum containing 'Ruby wrapper' ----------"

recordNumber=1

qbc.iterateRecords("8emtadvk",["Subject","Created","Message"],"{'0'.CT.'Ruby wrapper'}") {|record|

   print "\n\n#{recordNumber}."
   
   print "\nSubject: ", record["Subject"] 
   
   print "\nCreated: ", qbc.formatDate(record["Created"]) 
   
   message = record["Message"]
   message.gsub!("<BR/>","\n") if message.include?("<BR/>")
   
   print "\nMessage: ", message
   
   recordNumber += 1
}
