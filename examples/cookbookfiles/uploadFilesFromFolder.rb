
require 'QuickBaseClient'

def uploadFiles1(username,password,cwd)
  qbc = QuickBase::Client.new(username,password)
  dbid = qbc.findDBByName(cwd)
  if dbid.nil?
    puts "Creating a QuickBase application called '#{cwd}'."
    dbid = qbc.createDatabase(cwd,"Files uploaded from #{username}\'s #{cwd} folder.")
    qbc.addField(dbid, "Description","text")
    qbc.addField(dbid, "File Attachment","file")
  else
    puts "\nUsing the existing QuickBase application called '#{cwd}'.\n"
    qbc.getSchema(dbid)
    dbid = qbc.lookupChdbid(cwd.dup)
  end
  uploadFiles3(qbc,dbid,"File Attachment",cwd)
  puts "\nYou can repeat this upload using uploadFilesFromFolder.exe #{username} #{password} #{dbid} file_attachment"
end

def uploadFiles2(username,password,dbid,fieldName,cwd)
  qbc = QuickBase::Client.new(username,password)
  uploadFiles3(qbc,dbid,fieldName,cwd)
  puts "\nYou can repeat this upload using uploadFilesFromFolder.exe #{username} #{password} #{dbid} #{fieldName.gsub( /\W/, '_' )}."
end

def uploadFiles3(qbc,dbid,fieldName,cwd)
  Dir.foreach(cwd){|file|
    next if file == "." or file == ".."
    renamedFile = file.dup
    renamedFile.gsub!("&","And")
    renamedFile.gsub!("'"," ")
    if renamedFile != file
       File.rename(file,renamedFile)
    end
    puts "Uploading #{renamedFile}"
    qbc.uploadFile(dbid,renamedFile,fieldName)
  }
  puts "\nFinished uploading files."
end

def getInputAndRun
   mycwd = Dir.pwd.gsub('/','\\')

   if ARGV[3]
     uploadFiles2(ARGV[0],ARGV[1],ARGV[2],ARGV[3],mycwd)
   else
   
     print "\nPlease enter your QuickBase username: "
     username = gets.chomp
     print "\nPlease enter your QuickBase password: "
     password = gets.chomp
     print "\nEnter 'y' if to use or create a '#{mycwd}' QuickBase application for the files: "
     y = gets.chomp
     
     if y == "y" or y == "Y"
       uploadFiles1(username,password,mycwd)
     else
       print "\nPlease enter the id of your target QuickBase table: "
       dbid = gets.chomp
       print "\nPlease enter the name of the QuickBase File Attachment field in your table. (e.g. File): "
       fieldName = gets.chomp
       uploadFiles2(username,password,dbid,fieldName,mycwd)
     end
   end

end

getInputAndRun
