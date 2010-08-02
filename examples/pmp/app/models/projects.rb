class Projects < ActiveRecord::Base
   def self.all_projects
      projects = find_by_sql("All Projects")
      reportFields = connection.raw_connection.clist.split('.')
      return projects, reportFields
   end
   def self.my_open_projects
      find_by_sql("My Open Projects")
   end
   def self.open_projects
      find_by_sql("Open Projects")
   end
   def self.project_sorted_by_company
      find_by_sql("Project Sorted By Company")
   end
   def self.projects_sorted_by_priority
      dbid = connection.setActiveTable( "Projects" )
      qbAPIcommand = %q{ getAllValuesForFieldsAsArray(dbid,nil,nil,nil,"Projects Sorted By Priority") }
      connection.execute(qbAPIcommand)
   end
   def self.updated_projects
      projects = find_by_sql("Updated Projects")
      reportFields = connection.raw_connection.clist.split('.')
      return projects, reportFields
   end
end
