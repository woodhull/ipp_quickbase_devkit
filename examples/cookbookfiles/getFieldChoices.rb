
require 'QuickBaseClient'

qbc = QuickBase::Client.new("username","password")

# get the available choices for the 'Ingredient 1' field in the 
# 'Recipes' table of the 'QuickBase API Cookbook v2' application
choices = qbc.getFieldChoices( "bb2mad4sr", "Ingredient 1" )

if choices
   puts "\n------ Ingredients choices from the QuickBase API Cookbook v2 ------\n\n"
   puts choices.join("\n") 
end
