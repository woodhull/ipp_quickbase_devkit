
require 'rubygems'
gem 'twitter4r', '>=0.3.0'
require 'twitter'

require 'QuickBaseClient'

print "Please enter your QuickBase username: "
quickbase_username = gets.chop
print "Please enter your QuickBase password: "
quickbase_password = gets.chop
qbc = QuickBase::Client.new(quickbase_username,quickbase_password)

dbid = qbc.findDBByName("Twitter messages (#{quickbase_username})" )
if dbid.nil?
    dbid = qbc.createDatabase("Twitter messages (#{quickbase_username})", "This is a list of messages from Twitter.")
    qbc.addField(dbid,"Twitter_Screen_Name", "text")
    qbc.addField(dbid,"Twitter_Message", "text")
else   
  
  messagesToMoveToTwitter = []
  qbc.iterateRecords(dbid,["Record ID#","Twitter_Screen_Name","Twitter_Message"]){|record|
    if record["Twitter_Screen_Name"].nil? or record["Twitter_Screen_Name"] == "" and record["Twitter_Message"] and record["Twitter_Message"] != ""       
      messagesToMoveToTwitter << record["Twitter_Message"]
      qbc.deleteRecord(dbid,record["Record ID#"])
    end  
  }
  
  if messagesToMoveToTwitter.length > 0
    print "Please enter your Twitter username: "
    twitter_username = gets.chop
    print "Please enter your Twitter password: "
    twitter_password = gets.chop
    twitter_client = Twitter::Client.new(:login => twitter_username, :password => twitter_password )
    
    messagesToMoveToTwitter.each {|message|
      Twitter::Status.create(:text => message,:client => twitter_client)
    }
    
  end
  
end
