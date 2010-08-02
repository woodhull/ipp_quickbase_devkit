
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.getSchema(qbc.findDBByname("Application Library"))

qbc.printChildElements(qbc.qdbapi)

=begin

 :
 qdbapi :
  action  = API_getSchema
  errcode  = 0
  errtext  = No error
  table :
   name  = Application Library
   desc  = This QuickBase contains user and QuickBase created applications that can be used by any customer of QuickBase.
   original :
    table_id  = bbtt9cjr6
    cre_date  = 1152727983612
    mod_date  = 1171485722502
    next_record_id  = 1
    next_field_id  = 12
    next_query_id  = 5
    def_sort_fid  = 6
    def_sort_order  = 0
   chdbids :
    chdbid (name=_dbid_applications ) = bbtt9cjr7
    chdbid (name=_dbid_versions ) = bbtt9cjr8
    chdbid (name=_dbid_documents ) = bbtt9cjr9
    chdbid (name=_dbid_reviews ) = bbtt9cjsc
    chdbid (name=_dbid_installs_requests ) = bbvw9jb72
    chdbid (name=_dbid_feedback ) = bbt4qb5gr
    chdbid (name=_dbid_featured_apps ) = bbt9vg4u5
    chdbid (name=_dbid_categories ) = bbtt9cjsg
   lastluserid  = 0
   queries :
    query (id=1 ):
     qyname  = List All
     qytype  = table
     qycrit  = {0.CT.''}
     qycalst  = 0.0
    query (id=2 ):
     qyname  = List Changes
     qytype  = table
     qydesc  = Sorted by Date Modified
     qycrit  = {0.CT.''}
     qyopts  = so-D.onlynew.
     qycalst  = 0.0
   fields  =

=end
