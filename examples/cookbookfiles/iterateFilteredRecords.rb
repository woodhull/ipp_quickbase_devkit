
require 'QuickBaseClient'

qbc = QuickBase::Client.new

puts "----------------------------------------------------------------------"
puts "Latest Community Forum records with Subject beginning with A through E"
puts "----------------------------------------------------------------------"

qbc.iterateFilteredRecords("8emtadvk",[{"Subject"=>"^[A-E].+"}],nil,nil,"List Changes",nil,nil,"structured","num-100") {|record|
   puts record["Subject"]
}
