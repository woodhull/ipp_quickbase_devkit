
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

puts "\nSummary of types of published applications in the QuickBase Application Library:\n"
printf( "\n%-20s %10s %10s","Type","Count","Popularity\n")
qbc.iterateSummaryRecords("bbtt9cjr7", ["Type","Popularity"]){|record|
   if record["Type"]
      printf( "\n%-20s %10s %10s",record["Type"],record["Count"],record["Popularity:Total"])
   end
}
puts "\n\nCompare the output to Summary at the bottom of this report - \n\nhttps://www.quickbase.com/db/bbtt9cjr7?a=q&qid=28\n\n"
