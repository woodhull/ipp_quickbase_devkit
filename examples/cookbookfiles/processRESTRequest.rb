require 'QuickBaseClient'

qbc = QuickBase::Client.new(ENV["quickbase_username"],ENV["quickbase_password"])

puts "\nTable id for QuickBase Community Forum:\n\n"
puts qbc.processRESTRequest("QuickBase Community Forum")

puts "\nName of Community Forum table:\n\n"
puts qbc.processRESTRequest("8emtadvk")

puts "\nCommunity Forum record for Ruby wrapper:\n\n"
puts qbc.processRESTRequest("8emtadvk/24105")

puts "\nFunction Names listed in QuickBase Support Center:\n\n"
puts qbc.processRESTRequest("6ewwzuuj/Function Name")

puts "\nRecipe 93 from the QuickBase API Cookbook:\n\n"
puts qbc.processRESTRequest("QuickBase API Cookbook v3/Recipes/93")

puts "\nGet the title of Recipe 93 from the QuickBase API Cookbook:\n\n"
puts qbc.processRESTRequest("QuickBase API Cookbook v3/Recipes/93/Title")
