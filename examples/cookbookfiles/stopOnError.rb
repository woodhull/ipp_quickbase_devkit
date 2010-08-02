require 'QuickBaseClient.rb'

begin
   qbc = QuickBase::Client.new("username","password")
   qbc.stopOnError=true
   qbc.doQuery( "bad_database_id" ) # make a bad request
   qbc.doQuery( "bb2mad4sr" ) # QuickBase API Cookbook v2
rescue StandardError => exception
   puts "\n\n ***** Something went wrong during a request to QuickBase: ****\n#{exception}"
end
