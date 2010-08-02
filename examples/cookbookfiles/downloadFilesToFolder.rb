
require 'QuickBaseClient'

def downloadFiles1(username,password,cwd)
  qbc = QuickBase::Client.new(username,password)
  dbid = qbc.findDBByName(cwd)
  qbc.getSchema(dbid)
  dbid = qbc.lookupChdbid(cwd.dup)
  downloadFiles3(qbc,username,password,dbid,"File Attachment")
end

def downloadFiles2(username,password,dbid,fieldName)
  qbc = QuickBase::Client.new(username,password)
  qbc.getSchema(dbid)
  downloadFiles3(qbc,username,password,dbid,fieldName)
end

def downloadFiles3(qbc,username,password,dbid,fieldName)

   fieldNames = qbc.getFieldNames(dbid)
   clist = ""
   fid = ""
   fieldNames.each{|f|
      id = qbc.lookupFieldIDByName(f)
      fid = id.dup if f == fieldName
      clist << id
      clist << "."
   }
   clist[-1,1]=""

   if fid == ""
     fid = fieldName.dup
     fieldName = qbc.lookupFieldNameFromID(fid)
   end

   qbc.iterateRecords(dbid,fieldNames,nil,nil,nil,clist,"3"){|r|
      if r and r[fieldName] and r[fieldName].length > 0 
         next if r[fieldName].include?("https:") or r[fieldName].include?("http:")
         puts "Downloading #{r[fieldName]}"
         qbc.downLoadFile(dbid,r["Record ID#"],fid)
         if qbc.fileContents
            filename = r[fieldName]
            File.open( filename, "wb" ){|f|
               f.write(qbc.fileContents)
            }
         end   
      end
   }
  puts "\nFinished downloading files in QuickBase Record ID# order."
  puts "(Later copies of files overwrite previous copies)."
  puts "\nYou can repeat this download using downloadFilesToFolder.exe #{username} #{password} #{dbid} #{fid}."
end

def getInputAndRun
   mycwd = Dir.pwd.gsub('/','\\')

   if ARGV[3]
     downloadFiles2(ARGV[0],ARGV[1],ARGV[2],ARGV[3])
   else
   
     print "\nPlease enter your QuickBase username: "
     username = gets.chomp
     print "\nPlease enter your QuickBase password: "
     password = gets.chomp
     print "\nEnter 'y' if to download the files from a '#{mycwd}' QuickBase application: "
     y = gets.chomp
     
     if y == "y" or y == "Y"
       downloadFiles1(username,password,mycwd)
     else
       print "\nPlease enter the id of your QuickBase table: "
       dbid = gets.chomp
       print "\nPlease enter the name or id of the QuickBase File Attachment field in your table. (e.g. File): "
       fieldName = gets.chomp
       downloadFiles2(username,password,dbid,fieldName)
     end
   end

end

getInputAndRun
