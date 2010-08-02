
require 'QuickBaseClient'

qbc = QuickBase::Client.new(ARGV[0],ARGV[1])
qbc.getSchema(ARGV[2])
File.open("#{ARGV[2]}.schema.xml","w"){|f|f.write(qbc.qdbapi)}

# run this using 'ruby dumpSchema.rb <username> <password> <tableID>'
# e.g. 'ruby dumpSchema.rb fred@flinstone wilma 8emtadvk'


