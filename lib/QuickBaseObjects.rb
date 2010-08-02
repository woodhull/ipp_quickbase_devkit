#--#####################################################################
# Copyright (c) 2009 Gareth Lewis and Intuit, Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.opensource.org/licenses/eclipse-1.0.php
#
# Contributors:
#    Gareth Lewis - Initial contribution.
#    Intuit Partner Platform.
#++#####################################################################

require 'QuickBaseClient'

module QuickBase

module Objects

  # Generic list of attributes (used in Field class).
  class Attributes < Hash; end
  
  # Generic list of properties (used in Field and Query classes).
  class Properties < Hash; end  
  
  # List of Field definitions (used in Table class).
  class Fields < Hash; end
  
  # List of Choices for a multi-choice text field definition (used in Field class).
  class FieldChoices < Array; end
  
  # List of Application variables.
  class Variables < Hash; end

  # General info for Table and Application classes.
  class Info < Hash; end
  
  # List of Queries (used in Table class).
  class Queries < Hash; end
  
  # List of Tables - child tables of Application table. 
  class Tables < Hash; end
  
  # List of pages in an Application .
  class Pages < Hash; end  
  
  # List of Roles in an application.
  class Roles < Hash; end
  
  # List of Users in an Application.
  class Users < Hash; end
  
  # List of field values from a Record.
  class FieldValues < Hash; end
  
  # List of records returned by a Query.
  class Records < Array; end 
  
  # Definition of a Field built from the XML schema for a Table.
  class Field 
    attr_reader :name, :attributes, :properties
    attr_accessor :qbc
    def initialize(name = nil,type = nil,qbc = nil)
      set_qbc(qbc) if qbc
      @name = name || "new_field"
      @name = @name.strip.gsub(" ","_")
      @type = type || "text"
    end  
    def set_qbc(qbc)
      @qbc = qbc
      @dbid = qbc.dbid.dup
    end      
    def build(field_xml,qbc)
      @qbc = qbc
      @dbid = qbc.dbid.dup
      @id = field_xml.attributes["id"]
      @attributes = Attributes.new
      field_xml.attributes.each_attribute{|attribute|
        @attributes[attribute.expanded_name]=attribute.value
      }
      @properties = Properties.new
      @choices = FieldChoices.new
      fieldProc = proc { |element|
          if element.is_a?(REXML::Element) 
             if element.name == "choice"
               @choices << element.text
             else  
                @properties[element.name] = element.has_text? ? element.text : nil
             end
          end
      }
      @qbc.processChildElements(field_xml,true,fieldProc)
      @name = @properties["label"].strip.gsub(" ","_")
      @attributes.each{|key,value|
         self.class.send(:define_method,key){@attributes[key]}
      }
      @properties.each{|key,value|
         self.class.send(:define_method,key){@properties[key]}
      }
    end  
    def addChoice(choice, qbc = nil)
       set_qbc(qbc) if qbc
       @qbc.fieldAddChoices( @dbid, @id, choice )
    end  
    def removeChoice(choice, qbc = nil)
       set_qbc(qbc) if qbc
       @qbc.fieldRemoveChoices(@dbid, fid, choice) 
     end
    def setProperties(new_properties) 
       @properties.merge!(new_properties) if @qbc.setFieldProperties( @dbid, new_properties, @id )
    end      
  end 

  # Definition of a Query built from the XML schema for a Table.
  class Query 
    attr_reader :id, :name, :properties
    def build(query_xml,qbc)
      @qbc = qbc
      @dbid = qbc.dbid.dup
      @id = query_xml.attributes["id"]
      @properties = Properties.new
      queryProc = proc { |element|
          if element.is_a?(REXML::Element) 
             @properties[element.name] = element.has_text? ? element.text : nil
          end
      }
      @qbc.processChildElements(query_xml,true,queryProc)
      @properties.each{|key,value|
         self.class.send(:define_method,key){@properties[key]}
      }
      @name = @properties["qyname"]
    end
    # Run the Query and get the Records returned.
    def run
      ridFieldName = @qbc.lookupFieldNameFromID( "3")
      records = Records.new
      @qbc.iterateRecords(@dbid,@qbc.getFieldNames(@dbid),nil,@id,nil,qyclst()){|qb_record|
         record = Record.new
         record.build(@qbc,ridFieldName, qb_record)
         records << record
      }
      records
    end  
  end

  # Name and value of an Application variable.
  class Variable 
    attr_reader :name, :value
    def initialize(key=nil,value=nil)
      build(key,value) if key and value
    end  
    def build(key,value)
      @name = key
      @value = value
    end
  end

  # Definition of a Table built from the XML schema for the table.
  class Table 
    attr_reader :dbid, :name, :desc, :info, :tables, :queries, :fields, :pnoun
    def initialize(pnoun=nil)
        @pnoun = pnoun || "Records"
    end 
    def build(qbc,appTable=false)
        @qbc = qbc
        @dbid = qbc.dbid.dup
        @name = qbc.dbname.dup if qbc.dbname
        buildInfo
        buildFields
        buildQueries
        if appTable
           buildAppInfo
           buildVariables
           buildPages
           buildRoles
           buildUsers
           buildTables
        end
        self
      end
    def buildInfo
        buildInfoField("lastRecModTime",@qbc.lastRecModTime)
        buildInfoField("lastModifiedTime",@qbc.lastModifiedTime)
        buildInfoField("createdTime",@qbc.createdTime)
        buildInfoField("lastAccessTime",@qbc.lastAccessTime)
        buildInfoField("numRecords",@qbc.numRecords)
        buildInfoField("mgrID",@qbc.mgrID)
        buildInfoField("mgrName",@qbc.mgrName)
        buildInfoField("dbname",@qbc.dbname)
        buildInfoField("version",@qbc.version)
      end
    def buildAppInfo      
        buildInfoField("requestTime",@qbc.requestTime)
        buildInfoField("requestNextAllowedTime",@qbc.requestNextAllowedTime)
    end      
    def buildInfoField(key,value)
      @info ||= Info.new
      @info[key] = value
      self.class.send(:define_method,"i#{key}") {@info[key]}    
    end      
    def buildFields
      @fields ||= Fields.new
      fieldsProc = proc { |element|
          if element.is_a?(REXML::Element) and element.name == "field"
             buildField(element)
          end
       }
      @qbc.processChildElements(@qbc.fields,false,fieldsProc)
    end  
    def buildField(field_xml)
      field = Field.new
      field.build(field_xml,@qbc)
      @fields[field.id] = field
      addFieldMethods(field)
    end  
    def addFieldMethods(field)
       self.class.send(:define_method,"f#{field.name}") {@fields[field.id]}  
    end  
    def addField(field)
       raise "#{field} is not a Field object." if ! field.is_a?(Field)
       field.id = @qbc.addField(@dbid,field.name,field.type)
       @fields[field.id] = field
       addFieldMethods(field)
     end  
    def deleteField(field)
       raise "#{field} is not a Field object." if ! field.is_a?(Field)
       removeFieldMethods(field)
       @fields.delete(field.id)
       @qbc.deleteField(@dbid,field.id)
    end      
    def removeFieldMethods(field)
       raise "#{field} is not a Field object." if ! field.is_a?(Field)
       self.class.send(:remove_method,"f#{field.name}")  
    end      
    def buildVariables
      @variables ||= Variables.new
      @qbc.getApplicationVariables.each{|key,value| buildVariable(key,value)}
    end
    def buildVariable(key,value)
      variable = Variable.new
      variable.build(key,value)
      @variables[key] = variable
      addVariableMethods(variable)
    end
    def addVariableMethods(variable)
      self.class.send(:define_method,"v#{variable.name}") {@variables[variable.name].value}       
      self.class.send(:define_method,"v#{variable.name}=") {|valueToAssign|
         @variables[variable.name].value = valueToAssign
         @qbc.setDBVar(@dbid,variable.name,valueToAssign)
      }
    end  
    def buildTables
      @tables ||= Tables.new
      @qbc.getTableIDs(@dbid).each { |chdbid| buildTable(chdbid) }
    end  
    def buildTable(dbid)
      table = Table.new
      @qbc.getDBInfo(dbid)
      @qbc.getSchema(dbid)
      table.build(@qbc)
      @tables[dbid] = table
      addTableMethods(table)
    end
    def addTableMethods(table)
        self.class.send(:define_method,"t#{table.name.strip.gsub(' ','_')}"){@tables[table.dbid]}
    end  
    def buildQueries
      @queries ||= Queries.new
      queriesProc = proc { |element|
          if element.is_a?(REXML::Element) and element.name == "query"
             buildQuery(element)
          end
       }
      @qbc.processChildElements(@qbc.queries,false,queriesProc)
    end  
    def buildQuery(query_xml)
      query = Query.new
      query.build(query_xml,@qbc)
      @queries[query.id] = query
      self.class.send(:define_method,"q#{query.name.strip.gsub(' ','_')}"){@queries[query.id]}
    end  
    def buildPages
      @pages ||= Pages.new
      pageList = @qbc.getDBPagesAsArray(@dbid)
      pageList.each{|pageHash|buildPage(pageHash)}
    end     
    def buildPage(pageHash)
      page = Page.new
      page.build(pageHash)
      @pages[page.id]=page
      addPageMethods(page)
    end  
    def addPageMethods(page)
      self.class.send(:define_method,"p#{page.name.strip.gsub(' ','_')}"){@pages[page.id]}
      self.class.send(:define_method,"p#{page.name.strip.gsub(' ','_')}="){|pagebody|
         @pages[page.id].content = pagebody.dup
         @qbc.addReplaceDBPage(@dbid, page.id, nil, nil, pagebody)
      }
    end  
    def buildRoles
      @roles ||= Roles.new
      @qbc.getRoleInfo( @dbid ) {|role|buildRole(role)}
    end
    def buildRole(role_xml)
      role = Role.new
      role.build(role_xml,@qbc)
      @roles[role.id] = role
      self.class.send(:define_method,"r#{role.name.strip.gsub(' ','_')}"){@roles[role.id]}
    end
    def buildUsers
      @users ||= Users.new
      @qbc.userRoles(@dbid){|user_role_xml|buildUser(user_role_xml)}
    end
    def buildUser(user_role_xml)
      user = User.new
      user.build(user_role_xml,@qbc)
      @users[user.id] = user
      addUserMethods(user)
    end
    def addUserMethods(user)
       self.class.send(:define_method,"u#{user.name.strip.gsub(' ','_')}"){@users[user.id]}
    end      
    def runImport(importid)
      @qbc.runImport(@dbid,importid)
    end
  end

  # Definition and content of a page associated with an Application.
  class Page 
    attr_reader :id, :name, :type, :content
    def initialize(pageHash=nil)
      build(pageHash) if pageHash
    end  
    def build(pageHash)
       raise "#{pageHash} is not a Hash." if !pageHash.is_a?(Hash)
       @id = pageHash["id"] if pageHash["id"]
       @name = pageHash["name"] if pageHash["name"]
       @name ||= "Unnamed page"
       @type = pageHash["type"] if pageHash["type"]
       @type ||= "1"
       @content = pageHash["content"] if pageHash["content"]
    end            
  end

  # A Role associated with an Application.
  class Role 
    attr_reader :id, :name, :access_id, :access
    def build(role_xml,qbc)
      raise "role_xml is not an XML element" if !role_xml.is_a?(REXML::Element)
      @qbc = qbc
      @dbid = qbc.dbid.dup
      @id = role_xml.attributes["id"]
      @name = role_xml.elements["name"].text.dup
      @access = role_xml.elements["access"].text.dup
      @access_id = role_xml.elements["access"].attributes["id"]
    end  
    def addUser(user)
      raise "#{user} is not a User object" if !is_a?(User)
      @qbc.addUserToRole(@dbid,user.id,id)
    end  
    def removeUser(user)
      raise "#{user} is not a User object" if !is_a?(User)
      @qbc.removeUserFromRole(@dbid,user.id,role.id)
    end  
  end

  # A User with access to an Application.
  class User 
    attr_reader :id, :login, :screenName, :email, :name, :firstname, :lastname, :roles, :externalAuth
    def set_qbc(qbc)
       @qbc = qbc
       @dbid = qbc.dbid.dup
    end       
    def build(user_role_xml,qbc)
       raise "user_role_xml is not an XML element" if !user_role_xml.is_a?(REXML::Element)
       set_qbc(qbc)
       @id = user_role_xml.attributes["id"]
       @name = user_role_xml.elements["name"].text.dup
       @roles = []
       rolesProc = proc { |element|
          if element.is_a?(REXML::Element) and element.name == "role"
             roles << element.attributes["id"]
          end
       }
       qbc.processChildElements(user_role_xml,false,rolesProc)
    end  
    def addInfo(qbc,email)
       set_qbc(qbc)
       @qbc.getUserInfo(email)
       @name = @qbc.name
       @firstName = @qbc.firstName
       @lastName = @qbc.lastName
       @login = @qbc.login
       @email = @qbc.email
       @screenName = @qbc.screenName
       @externalAuth = @qbc.externalAuth
       @id = @qbc.userid
       @qbc.getUserRole(@dbid, @id)
       @roles ||= []
       @roles << @qbc.roleid.dup
    end      
    def changeRole(role,new_role)
      raise "#{role} is not a Role object" if !is_a?(Role)
      raise "#{new_role} is not a Role object" if !is_a?(Role)
      @qbc.addUserToRole(@dbid,id,role.id,new_role.id)
    end  
  end

  # An Application, which is a Table with child Tables, Pages, Roles, Variables.
  class Application < Table
    attr_reader :pages, :roles, :users, :variables
    def addTable(table)
      raise "#{table} is not a Table object" if !is_a?(Table)
      newdbid = @qbc.createTable(@dbid, table.pnoun)
      @tables[newdbid] = table
      addTableMethods(table)
    end
    def addVariable(variable)
      raise "#{variable} is not a Variable object" if !is_a?(Variable)
      @variables[variable.name] = variable
      addVariableMethods(variable)
    end
    def addPage(page)
      raise "#{page} is not a Page object" if !is_a?(Page)
      pageid = @qbc.addReplaceDBPage(@dbid,nil,page.name, page.type, page.content)
      page.build( {"id" => pageid})
      @pages[pageid] = page
      addPageMethods(page)
    end  
    def addUser(role,email,fname,lname,message)
        raise "#{role} is not a Role object" if !is_a?(Role)
        userid = @qbc.provisionUser(@dbid, role.id, email, fname, lname)
        if userid
           if @qbc.sendInvitation(@dbid, userid, message) 
               user = User.new
               user.addInfo(qbc,email)
           end  
        end
    end      
    def rename(newappname)
        @qbc.renameApp(@dbid, newappname)
    end      
  end
  
  # Name and value of a field in a Record return by a Query. 
  class FieldValue
    attr_reader :name, :value
    def initialize(k,v)
       @name = k.dup
       @value = v.dup
    end  
  end
  
  # A Record returned by a Query.
  class Record 
    attr_reader :id, :fieldValues
    def build(qbc, ridFieldName,qb_record)
       @qbc = qbc
       @dbid = qbc.dbid.dup
       @fieldValues = FieldValues.new
       qb_record.each{|k,v|
          @id = v if k == ridFieldName
          fieldValue = FieldValue.new(k,v)
          @fieldValues[fieldValue.name] = fieldValue.value
          addMethods(fieldValue)
       }
     end  
     def addMethods(fieldValue)
          self.class.send(:define_method,"f#{fieldValue.name.strip.gsub(' ','_')}"){@fieldValues[fieldValue.name]}
          self.class.send(:define_method,"f#{fieldValue.name.strip.gsub(' ','_')}="){|valueToAssign|
             @fieldValues[fieldValue.name] = valueToAssign
             @qbc.setFieldValue(fieldValue.name,valueToAssign,@dbid,@id)
          }
     end  
  end

  # Build objects using XML from QuickBase 
  class Builder
    def initialize(username=nil,password=nil,qbc=nil)
      @qbc = qbc || Client.new(username,password)
      @qbc.cacheSchemas=true
    end 
    def application(application_name)
      dbid = @qbc.findDBByName(application_name)
      if dbid
        @qbc._getAppDTMInfo
        @qbc._getDBInfo
        @qbc._getSchema
        a = Application.new
        a.build(@qbc,true)
      else
        raise "Could not find the application named '#{application_name}'."        
      end
    end
    def table(dbid)
      begin
        @qbc.getDBInfo(dbid)
        @qbc.getSchema(dbid)
        t = Table.new
        t.build(@qbc)
      rescue
        raise "Could not find the table using '#{dbid}' as a dbid."        
      end
    end
  end  

end # module Objects

end # module QuickBase

def applicationObjectExample
  
  qbob = QuickBase::Objects::Builder.new(ENV["quickbase_username"],ENV["quickbase_password"])
  
  cookbookApp = qbob.application("QuickBase API Cookbook v3")
  
  puts "\n\nApplication name:\n"
  puts cookbookApp.name

  puts "\n\nApplication roles:\n"
  cookbookApp.roles.each_value{|role|puts "name: #{role.name}, id: #{role.id}, access: #{role.access}"}

  puts "\n\nApplication users:\n"
  cookbookApp.users.each_value{|user|puts "id: #{user.id}"}

  puts "\n\nApplication variables:\n"
  cookbookApp.variables.each_value{|variable|puts "#{variable.name}: #{variable.value}"}

  puts "\n\nValue of application variable 'TestVariable':\n"
  puts cookbookApp.vTestVariable

  puts "\n\nApplication pages:\n"
  cookbookApp.pages.each_value{|page|puts page.name}

  puts "\n\nDefault application page:\n"
  puts cookbookApp.pDefault_Dashboard.name
  
  puts "\n\nTables from the QuickBase API Cookbook v3:\n"
  cookbookApp.tables.each_value{|table|puts table.name}
  
  puts "\n\nQueries from the Recipes table:\n"
  cookbookApp.tRecipes.queries.each_value{|query|puts query.name}

  puts "\n\nProperties of the List All query from the Recipes table:\n"
  cookbookApp.tRecipes.qList_All.properties.each_pair{|key,value|puts "#{key}: #{value}" }

  puts "\n\nRecord Titles from the List All query from the Recipes table:\n"
  records = cookbookApp.tRecipes.qList_All.run 
  records.each{|record| puts record.fTitle}

  puts "\n\nColumns of the List All query from the Recipes table:\n"
  puts cookbookApp.tRecipes.qList_All.qyclst
  
  puts "\n\nFields from the Ingredients table:\n"
  cookbookApp.tIngredients.fields.each_value{|field|puts field.name}
  
  puts "\n\nField ID of the Description field in the Ingredients table:\n"
  puts cookbookApp.tIngredients.fDescription.id

  puts "\n\nName of field 7 from the Ingredients table:\n"
  puts cookbookApp.tIngredients.fields["7"].name


end

#applicationObjectExample
