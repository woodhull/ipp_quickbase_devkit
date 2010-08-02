
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# make a list of the tables to be joined
tablesToJoin = Array.new

table1 = Hash.new
table1["dbid"]="bccr737mz"              #table id
table1["fields"] = Array["a","b","c"] #fields to retrieve
table1["joinfield"] = "c"                 #field to compare across all tables' records
tablesToJoin << table1

table2 = Hash.new
table2["dbid"]="bccr737m2"
table2["fields"] = Array["c","d","e"]
table2["joinfield"] = "c"
tablesToJoin << table2

table3 = Hash.new
table3["dbid"]="bccr737m3"
table3["fields"] = Array["cc","g","gf"]
table3["joinfield"] = "cc"
tablesToJoin << table3

puts "------ Joined records from 3 tables ------"
recnum = 1
qbc.iterateJoinRecords(tablesToJoin) {|joinedRecord|
   print "\n#{recnum}. "
   joinedRecord.each{|field,value|
      print "#{field}: #{value}, "
   }
   recnum += 1
}

=begin

The output using unrealistically simple data is below.
Note that field 'c' is in two tables and is merged.
The value of 'c' from the second table is included in the joined record.

------ Joined records from 3 tables ------

1. cc: c, a: a2, b: b2, c: c, d: d, e: e, g: g, gf: sda,
2. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: cv, gf: sdafad,
3. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: sad, gf: sad,
4. cc: c, a: a2, b: b2, c: c, d: d, e: e, g: sad, gf: sad,
5. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: g, gf: sda,
6. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: cv, gf: sdafad,
7. cc: c, a: a2, b: b2, c: c, d: d, e: e, g: sad, gf: sad,
8. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: sad, gf: sad,
9. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: g, gf: sda,
10. cc: c, a: a2, b: b2, c: c, d: d, e: e, g: cv, gf: sdafad,
11. cc: c, a: a2, b: b2, c: c, d: sadf, e: df, g: sad, gf: sad,
12. cc: c, a: a, b: b, c: c, d: d, e: e, g: g, gf: sda,
13. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: cv, gf: sdafad,
14. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: sad, gf: sad,
15. cc: c, a: a, b: b, c: c, d: d, e: e, g: sad, gf: sad,
16. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: g, gf: sda,
17. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: cv, gf: sdafad,
18. cc: c, a: a, b: b, c: c, d: d, e: e, g: sad, gf: sad,
19. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: sad, gf: sad,
20. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: g, gf: sda,
21. cc: c, a: a, b: b, c: c, d: d, e: e, g: cv, gf: sdafad,
22. cc: c, a: a, b: b, c: c, d: sadf, e: df, g: sad, gf: sad,

=end
