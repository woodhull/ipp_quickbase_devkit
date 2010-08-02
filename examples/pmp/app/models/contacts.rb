class Contacts < ActiveRecord::Base
   def self.project_contacts
      
      projectsTablesAndFields = {}
      projectsTablesAndFields["dbid"] = connection.setActiveTable("Projects")
      projectsTablesAndFields["fields"] = Array["Company","Project Name"]
      projectsTablesAndFields["joinfield"] = "Company"
      
      contactsTablesAndFields = {}
      contactsTablesAndFields["dbid"] = connection.setActiveTable("Contacts")
      contactsTablesAndFields["fields"] = Array["Name","Company","Title","E-mail Address"]
      contactsTablesAndFields["joinfield"] = "Company"
      
      connection.raw_connection.getJoinRecords([projectsTablesAndFields,contactsTablesAndFields])
      
   end
   def self.companies
      projects = {}
      contacts = {}
      projects["dbid"] = connection.setActiveTable("Projects")
      contacts["dbid"] = connection.setActiveTable("Contacts")
      tables = Array[projects,contacts]
      fields = Array["Company"]
      connection.raw_connection.getUnionRecords(tables,fields)
   end
end
