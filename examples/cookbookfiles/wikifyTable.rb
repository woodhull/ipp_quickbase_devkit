require 'QuickBaseclient'

qbc = QuickBase::Client.new(ENV["quickbase_username"],ENV["quickbase_password"])

dbid = "bdeapkrmj"
baseURL = "https://www.quickbase.com/db/#{dbid}?a=dr&rid="
links = {}

# collect all the possible links in the table using the values in a particular text field
qbc.iterateRecords(dbid,["Record ID#","tag"]){|record|
  if record["tag"] and record["tag"].length > 0
    links[record["tag"]] = "<a href='#{baseURL}#{record["Record ID#"]}&rl=rfe'>#{record['tag']}</a>"
  end  
}

# loop through all the values in a particular HTML text field and insert links to other records 
if links.length > 0
  qbc.iterateRecords(dbid,["Record ID#","text"]){|record|
    newText = record["text"].dup
    newText.gsub!("<BR/>","")
    links.each{|tag,url| 
      newText.gsub!(url,tag) # remove existing link so we don't duplicate it
      newText.gsub!(tag,url) 
    }
    qbc.clearFieldValuePairList
    qbc.addFieldValuePair("text",nil,nil,newText)
    qbc.editRecord(dbid,record["Record ID#"],qbc.fvlist)
  }
end
