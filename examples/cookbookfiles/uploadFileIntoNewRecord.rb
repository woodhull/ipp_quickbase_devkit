
require 'QuickBaseClient'

qbc = QuickBase::Client.new( "username", "password" )

# upload the local file "cookbookfiles.zip" into the 'File Attachment' field in a new record 
# in the 'Etc.' table in the QuickBase API Cookbook v2
qbc.uploadFile( "bb2mad4su", "cookbookfiles.zip", "File Attachment" )
