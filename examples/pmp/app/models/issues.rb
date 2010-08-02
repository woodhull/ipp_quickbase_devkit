class Issues < ActiveRecord::Base
   def self.filter_issues(regularExpression)
      dbid = connection.setActiveTable("Issues")
      connection.execute("getFilteredRecords('#{dbid}',[{'Issue Name'=>'#{regularExpression}'},'Description','Resolution','Priority'])")
   end
end
