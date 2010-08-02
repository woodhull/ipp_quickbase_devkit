require 'QuickBaseClient'

qbc = QuickBase::Client.new(ENV["quickbase_username"],ENV["quickbase_password"])

runningTotal = 0
qbc.iterateRecords("bdcvpsxpy",qbc.getFieldNames("bdcvpsxpy"),nil,nil,"List All by Date Created"){|record|
  runningTotal += record['number'].to_i
  qbc.clearFieldValuePairList
  qbc.addFieldValuePair("running total",nil,nil,runningTotal.to_s)
  qbc.editRecord("bdcvpsxpy",record['Record ID#'],qbc.fvlist)
}
