
require 'rubygems'
gem 'twitter4r', '>=0.3.0'
require 'twitter'

# ----------------------------------------------------------------------
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
end

# ----------------------------------------------------------------------
print "Please enter your Twitter username: "
twitter_username = gets.chop

print "Please enter your Twitter password: "
twitter_password = gets.chop

twitter_client = Twitter::Client.new(:login => twitter_username, :password => twitter_password )
timeline = twitter_client.timeline_for(:public) do |status|
  qbc.clearFieldValuePairList
  qbc.addFieldValuePair("Twitter_Screen_Name",nil,nil,status.user.screen_name)
  qbc.addFieldValuePair("Twitter_Message",nil,nil,status.text)
  qbc.addRecord(dbid,qbc.fvlist)
end
