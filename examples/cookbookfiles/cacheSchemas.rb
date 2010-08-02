require 'QuickBaseClient'

qbc = QuickBase::Client.new

# get the schema for the QuickBase Community Forum
firstTime=true
2.times {

  totalTime = Time.now
  
  8.times {
    getSchemaTime = Time.now
    qbc.getSchema("bbqm84dzy")
    puts "getSchema took #{Time.now-getSchemaTime} seconds"
  }
  
  puts "\nTotal time: #{Time.now-totalTime} seconds"
  
  qbc.signOut
  qbc = QuickBase::Client.new
  qbc.cacheSchemas = true
  puts "Caching schema..." if firstTime
  firstTime = false
}

=begin

Sample output of the above script:-

getSchema took 1.438 seconds
getSchema took 0.515 seconds
getSchema took 0.5 seconds
getSchema took 0.485 seconds
getSchema took 0.515 seconds
getSchema took 0.532 seconds
getSchema took 0.484 seconds
getSchema took 0.5 seconds

Total time: 4.969 seconds
Caching schema...
getSchema took 0.515 seconds
getSchema took 0.016 seconds
getSchema took 0.015 seconds
getSchema took 0.0 seconds
getSchema took 0.016 seconds
getSchema took 0.0 seconds
getSchema took 0.016 seconds
getSchema took 0.031 seconds

Total time: 0.609 seconds

=end

