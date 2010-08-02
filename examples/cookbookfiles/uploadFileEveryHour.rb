require 'QuickBaseClient'

loop {
  qbc = QuickBase::Client.new( "my_username", "my_password", "my_application" )
  qbc.lookupChdbid( "Documents" ) # the table containing the files

  # "12" is the number of the record (Record ID#) to be modified
  # "Document" is the name of the field containing a file attachment
  # "Version" and "Date" are additional field values to modify in the record

  qbc.updateFile( qbc.dbid, "12", "my_file.doc", "Document", { "Version" => "6",   "Note" => "Updated 01/30/2006" } )

  qbc.signOut
  qbc = nil

  # wait one hour
  sleep(60*60)
}