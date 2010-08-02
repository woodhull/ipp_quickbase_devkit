
require 'QuickBaseClient'

# Add an Authors table to a Books application

qbc = QuickBase::Client.new( "username","password","Books")

qbc.createTable("Authors")

qbc._addField("Name", "text")


