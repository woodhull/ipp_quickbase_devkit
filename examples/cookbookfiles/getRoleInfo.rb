
require 'QuickBaseClient'

qbc = QuickBase::Client.new

puts "\nRoles in the QuickBase Community Forum\n\n"

qbc.getRoleInfo("bbqm84dzy") { |role|
  puts "id: #{role.attributes['id']}"
  puts "name: #{role.elements['name'].text}"
  puts "access id: #{role.elements['access'].attributes['id']}"
  puts "access name: #{role.elements['access'].text}"
  puts "============================="
}

=begin

Output of the above script:

Roles in the QuickBase Community Forum

id: 10
name: Viewer
access id: 3
access name: Basic Access
=============================
id: 11
name: Participant
access id: 3
access name: Basic Access
=============================
id: 12
name: Administrator
access id: 1
access name: Administrator
=============================
id: 17
name: Product Manager
access id: 1
access name: Administrator
=============================
id: 18
name: Participant with Modify Own
access id: 3
access name: Basic Access
=============================

=end
