require 'QuickBaseClient'

qbc = QuickBase::Client.new
serverStatus = qbc.getServerStatus

puts "\nversion: #{serverStatus['version']}"
puts "users:     #{serverStatus['users']}"
puts "groups:    #{serverStatus['groups']}"
puts "databases: #{serverStatus['databases']}"
puts "uptime:    #{serverStatus['uptime']}"
puts "updays:    #{serverStatus['updays']}"
