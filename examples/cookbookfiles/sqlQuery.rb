
require 'QuickBaseClient'
qbc = QuickBase::Client.new("username","password","QuickBase Community Forum")
recs = qbc.doSQLQuery("SELECT Subject,Message FROM Messages WHERE Subject = 'Ruby wrapper for QuickBase HTTP API'",:Array)
recs.each{ |rec| 
   subject = rec['Subject']
   message = rec['Message']
   message.gsub!("<BR/>","\n")
   puts "Subject: --------------- #{subject} ---------------\nMessage: #{message}\n\n"
}

