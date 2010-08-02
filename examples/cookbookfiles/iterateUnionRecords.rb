
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# make a list of the tables to be merged
table1 = Hash.new
table1["dbid"]="bccr737mz"
table2 = Hash.new
table2["dbid"]="bccr737m2"
tablesToMerge = Array[table1,table2]

# fields are expected to be the same in both tables
fields = Array["c"]

puts "------ Merged records from 2 tables ------"
recnum = 1
qbc.iterateUnionRecords(tablesToMerge,fields) {|uniqueRecord|
   print "\n#{recnum}. "
   uniqueRecord.each{|field,value|
      print "#{field}: #{value}, "
   }
   recnum += 1
}

=begin

The output using unrealistically simple data is below.

------ Merged records from 2 tables ------

1. c: ad,
2. c: c,
3. c: c1,
4. c: v,
5. c: Get records containing a certain value,

=end
