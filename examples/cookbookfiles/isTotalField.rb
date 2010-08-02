require 'QuickBaseClient'

qbc = QuickBase::Client.new

qbc.getSchema("8emtadvk")
if qbc.isTotalField?("Subject")
    puts "The 'Subject' field in the QuickBase Community Forum has a Total at the bottom of reports."
else
    puts "The 'Subject' field in the QuickBase Community Forum does not have a Total at the bottom of reports."
end

if qbc.isTotalField?("# of Posts")
    puts "The '# of Posts' field in the QuickBase Community Forum has a Total at the bottom of reports."
else
    puts "The '# of Posts' field in the QuickBase Community Forum does not have a Total at the bottom of reports."
end
