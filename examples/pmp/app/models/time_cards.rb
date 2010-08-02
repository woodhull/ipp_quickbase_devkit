class TimeCards < ActiveRecord::Base
   def self.summary
      dbid = connection.setActiveTable("Time Cards")
      fieldNames = Array["Project Name","Week Starting On","Sun","Mon","Tue","Wed","Thu","Fri","Sat","Weekly Total"]
      connection.raw_connection.getAllValuesForFieldsAsArray( dbid, fieldNames )
   end
end
