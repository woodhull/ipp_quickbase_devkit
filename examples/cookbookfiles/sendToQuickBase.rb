require 'QuickBaseClient'

if ARGV[0] and File.exist?(ARGV[0]) and ARGV[0].rindex("\\")
  username = ARGV[1] || ENV["quickbase_username"]
  password = ARGV[2] || ENV["quickbase_password"]
  if username.nil?
    print "Please enter your QuickBase user name: "
    username = gets.chop
  end
  if password.nil?
    print "Please enter your QuickBase password: "
    password = gets.chop
  end    
  qbc = QuickBase::Client.new(username, password)
  folder = ARGV[0][0,ARGV[0].rindex("\\")]
  file = ARGV[0][ARGV[0].rindex("\\")+1,ARGV[0].length]
  dbid = qbc.findDBByName(folder)
  if dbid.nil?
    dbid = qbc.createDatabase(folder,"Files uploaded from #{folder}")
    qbc.addField(dbid, "Description","text")
    qbc.addField(dbid, "File Attachment","file")
  else
    qbc.getSchema(dbid)
    dbid = qbc.lookupChdbid(folder.dup)
  end
  Dir.chdir(folder)
  qbc.uploadFile(dbid,file.dup,"File Attachment")
else
  puts "\n\nusage: ruby sendToQuickBase.rb <filepath> [username] [password]"
  puts "\ne.g. ruby sendToQuickBase.rb c:\temp\mySpecialFile"
  puts "\nYou can omit your username and password if they are in environment"
  puts "variables 'quickbase_username' and 'quickbase_password'.\n\n"
end
