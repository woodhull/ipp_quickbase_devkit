require 'QuickBaseEventNotifier'

# check the QuickBase Community Forum every minute for new or modified records
QuickBase::EventNotifier.watchAndRunCode("username","password","8emtadvk") {|eventNotification|
   # run this code when a record is added or modified   
   qbc = QuickBase::Client.new("username","password")
   fiveMinutesAgo = Time.now - (60*5)
   qbc.doQuery("8emtadvk", "{'2'.GT.'#{fiveMinutesAgo.to_i}'}"){ |record|
      # print records added less than 5 minutes ago
      qbc.printChildElements(record)
   }
}
