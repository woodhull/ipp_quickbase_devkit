require 'QuickBaseClient'

qbc = QuickBase::Client.new

qbc.getSchema("93htvp8y")

if qbc.isAverageField?("Subject")
    puts "The 'Subject' field in the QuickBase Community Forum has an Average at the bottom of reports."
else
    puts "The 'Subject' field in the QuickBase Community Forum does not have a Average at the bottom of reports."
end

if qbc.isAverageField?("# of Posts")
    puts "The '# of Posts' field in the QuickBase Community Forum has a Average at the bottom of reports."
else
    puts "The '# of Posts' field in the QuickBase Community Forum does not have a Average at the bottom of reports."
end
