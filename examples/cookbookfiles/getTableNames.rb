
require 'QuickBaseClient'

qbc = QuickBase::Client.new
tableNames = qbc.getTableNames("bbtt9cjr6")
puts "\nTables in the QuickBase Application Library:\n\n"
puts tableNames.join( "\n")

=begin
Output of the above script:

Tables in the QuickBase Application Library:

Applications
Versions
Files
Reviews
Activity Log
Bookmarks
Feedback
Featured Apps
Categories

=end

