
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

qbc.getUserInfo( "fred_flinstone@internet.com")

qbc.getUserRole("bbqm84dzy",qbc.userid)

puts "user id  : #{qbc.userid}"
puts "user name: #{qbc.username}"
puts "role id  : #{qbc.roleid}"
puts "role name: #{qbc.rolename}"
puts "access id: #{qbc.accessid}"
puts "access   : #{qbc.access}"
