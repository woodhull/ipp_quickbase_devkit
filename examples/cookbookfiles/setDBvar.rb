
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password","My Appointments")

qbc._setDBvar("HourlyRate","350.00")
