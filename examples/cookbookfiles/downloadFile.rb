require 'QuickBaseClient'

qbc = QuickBase::Client.new

# download the QuickBaseClient.rb.zip from record 24105 in the QuickBase Community Forum
# '41' is the field ID of the File Attachment field
qbc.downLoadFile("8emtadvk", "24105", "41" )

# have to write the downloaded data before it exists on your local disk
File.open( "The.Latest.QuickBaseClient.rb.zip", "wb" ){|f|f.write(qbc.fileContents)}
