
require 'QuickBaseClient'

#There are two ways to set the URL for your company

# 1)
qbc1 = QuickBase::Client.new( "fred_flinstone@internet.com", "wilma", nil, true, false, false, false, "mycompany" )

# 2)
qbc2 = QuickBase::Client.new( "fred_flinstone@internet.com", "wilma")
qbc2.setqbhost( true, "mycompany" )

