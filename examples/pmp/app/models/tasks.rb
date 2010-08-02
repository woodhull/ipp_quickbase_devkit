class Tasks < ActiveRecord::Base
   def self.search(searchString)
      searchString.gsub!("'","")
      find_by_sql("{'0'.CT.'#{searchString}'}")
   end
   def self.search2(status)
      find_by_sql("SELECT * FROM Tasks WHERE Status = '#{status}'")
   end
   def self.search3(status)
      find_all_by_status(status)
   end
end
