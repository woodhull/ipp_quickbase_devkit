

require 'QuickBaseClient'

qbc = QuickBase::Client.new

puts "\n\nDescription of QuickBase API Cookbook application:\n\n"

puts qbc.bcdcajmrf.xml_desc

puts "\n\nIngredients from the QuickBase API Cookbook:\n\n"

qbc.bcdcajmrh.qid_1.printChildElements(qbc.records)

puts "\n\nValue of field 6 from record 24105 in table 8emtadvk:\n\n"

puts qbc.dbid_8emtadvk.rid_24105.fid_6 # prints 'Ruby wrapper for QuickBase HTTP API'
















