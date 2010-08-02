require 'QuickBaseClient'
require 'QuickBaseMisc'

username = ARGV[0] || ENV["quickbase_username"] 
password = ARGV[1] || ENV["quickbase_password"] 

qbc = QuickBase::Client.new(username,password)

cwd = Dir.pwd.gsub('/','\\')

dbid = qbc.findDBByName(cwd)
if dbid.nil?
  dbid = qbc.createDatabase(cwd,"#{username}'s slide show from #{cwd}.")
  qbc.addField(dbid,"Picture","file")
  qbc.addField(dbid,"HtmlPage","file")
else  
  qbc.getSchema(dbid)
  dbid = qbc.lookupChdbid(cwd.dup)
  qbc.getSchema(dbid)
end  
pictureFieldID = QuickBase::Misc.decimalToBase32(6)
htmlPageFieldID = QuickBase::Misc.decimalToBase32(7)
Dir.foreach(cwd){|file|
  next unless [".jpeg", ".jpg",".gif",".bmp",".png"].include?(file.downcase[file.rindex('.'),file.length])
  renamedFile = file.dup
  renamedFile.gsub!("&","And")
  renamedFile.gsub!("'"," ")
  if renamedFile != file
     File.rename(file,renamedFile)
  end
  puts "Uploading #{renamedFile}"
  rid, updateid = qbc.uploadFile(dbid, renamedFile.dup, "Picture")
  thisRid = QuickBase::Misc.decimalToBase32(rid.to_i)
  prevRid = QuickBase::Misc.decimalToBase32(rid.to_i-1)
  nextRid = QuickBase::Misc.decimalToBase32(rid.to_i+1)
  pictureURL = "https://www.quickbase.com/up/#{dbid}/g/r#{thisRid}/e#{pictureFieldID}/va/#{renamedFile.dup}"
  prevHtmlURL = "https://www.quickbase.com/up/#{dbid}/g/r#{prevRid}/e#{htmlPageFieldID}/va/slide.html"
  nextHtmlURL = "https://www.quickbase.com/up/#{dbid}/g/r#{nextRid}/e#{htmlPageFieldID}/va/slide.html"
  html = "<center><img src=\"#{pictureURL}\" /><br>#{renamedFile.dup}<b>#{}</b><hr><a href=\"#{prevHtmlURL}\">Previous</a> <a href=\"#{nextHtmlURL}\">Next</a></center>"
  File.open("slide.html","w"){|f|f.write(html)}
  qbc.updateFile(dbid,rid,"slide.html","HtmlPage")
}
