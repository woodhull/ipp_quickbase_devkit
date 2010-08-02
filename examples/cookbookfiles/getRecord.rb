require 'QuickBaseClient'
qbc = QuickBase::Client.new
qbc.getRecord("24105","8emtadvk"){|myRecord| 
  myRecord.each{|key,value| puts "Field: #{key}, Value: #{value}\n" }
}
