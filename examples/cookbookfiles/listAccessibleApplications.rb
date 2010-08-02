require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")
qbc.grantedDBs() { |database|
   qbc.printChildElements(database)
}
