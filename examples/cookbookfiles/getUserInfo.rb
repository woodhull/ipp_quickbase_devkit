
require 'QuickBaseClient'

def displayUserInfo( qbc, emailAddress = nil)
  
  qbc.getUserInfo emailAddress

  puts "name        : #{qbc.name}"
  puts "first name  : #{qbc.firstName}"
  puts "last name   : #{qbc.lastName}"
  puts "login       : #{qbc.login}"
  puts "email       : #{qbc.email}"
  puts "screen name : #{qbc.screenName}"
  puts "externalAuth: #{qbc.externalAuth}"
  puts "user id     : #{qbc.userid}"

end


qbc = QuickBase::Client.new("username","password")

puts "\n\nInformation in QuickBase about the person running this script:\n\n"
displayUserInfo(qbc)

puts "\n\nInformation in QuickBase about fred_flinstone@internet.com:\n\n"
displayUserInfo(qbc, "fred_flinstone@internet.com")
