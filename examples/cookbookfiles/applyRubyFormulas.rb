require 'QuickBaseClient'

qbc = QuickBase::Client.new(ENV["quickbase_username"],ENV["quickbase_password"])
qbc.iterateRecords("bdcvpsxpy",qbc.getFieldNames("bdcvpsxpy")){|record|
  nameAndNumber = eval(record['ruby formula 1']) || "<name and number>"
  qbc.clearFieldValuePairList
  qbc.addFieldValuePair("name+number",nil,nil,nameAndNumber)
  qbc.editRecord("bdcvpsxpy", record['Record ID#'],qbc.fvlist)
}

