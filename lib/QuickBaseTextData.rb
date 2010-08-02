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

=begin rdoc

The data file format processed by this class is:-

application: <application name>
table: <table name>
dbid: <dbid>
record: [record id#]
<field name>: value
<field name>: value
...
record:
<field name>: value
<field name>: value

1) application:, table:, dbid:, record: <field name>: must appear at the beginning of a line.
2) Except for text fields, whitespace will be trimmed from field values.
3) Lines starting with whitespace are processed as data for a multi-line text field. 
   The first whitespace character will be ignored.
4) If <application name> is followed by 'record:' , the table is assumed to have the 
    same name as the application, as in a single-table application.
5) <dbid> will change the target/source table for any subsequent 'record:'.  
    When possible, use <dbid> instead of <application name> and <table name>.
6) If <application name> refers to a non-existent application, the <application name> will be created
    as a new single-table application and <table name> will be ignored.
7) If <field name>: is not an existing field and is followed by a valid field type name, such as 'date', 
    the <field name> field wil be added to the QuickBase table. Field properties can appear after the
    field type.
8) If <field name> is a number and is not an existing field, the field will be treated as a QuickBase field id.    
9) If record: is followed by a number, the number is assumed to be the id of an existing record, and data
    in subsequent <field name>: will overwite existing fields when sent to QuickBase.
    
    
Example:

application:Email Inbox
table:Messages
record:
From: my@email.com
Date Sent: 12/31/2007
Subject:Testing TextData class
Body: This is a test of the TextData class.
 This is a multi-line text field.
 
=end

# Class to read and write human-editable text files of data that can be sent to QuickBase. 
# The file format can also be used as a simple intermediate format for getting data into
# QuickBase programmatically from other sources.  This format is better than CSV for 
# human-readability and allows fields to be skipped and to appear in any sequence.   
# The format is like yaml, probably isn't a subset of it, but is simpler.
class TextData

   attr_reader :dbid
   
   def initialize(username,password)
      @username,@password=username,password
   end

   #  Read a file in the format described above and send the data to QuickBase.
   #  Records are added or edited when tables, fields and values have been validated
   #  and all the data for a record has been accumulated.
   #  Any error in the input file will stop further processing of the file.
   def sendDataToQuickBase(inputFilename, errorFilename)
         @errorFilename = errorFilename
         if FileTest.exist?(inputFilename) 
            if login
               lineNumber = 1
               begin
                  IO.foreach(inputFilename){|line|
                     if line.index( "application:") == 0
                        line.sub!("application:","")
                        line.strip!
                        setApplication(line)
                     elsif line.index( "table:") == 0
                        line.sub!("table:","")
                        line.strip!
                        setTable(line)
                     elsif line.index( "dbid:") == 0
                        line.sub!("dbid:","")
                        line.strip!
                        setDBID(line)
                     elsif line.index( "record:") == 0
                        line.sub!("record:","")
                        line.strip!
                        if line.match(/[0-9]+/)
                           setRecord(line)
                        else
                           setRecord(nil)
                        end
                     elsif line.match( /^([^:]+):(.*)$/)
                        setFieldValue($1, $2)
                     elsif line.match( /^([\s\t])(.*)$/)
                        appendFieldValue($2)
                     end
                     lineNumber = lineNumber + 1
                  }
                  addOrEditRecord
               rescue StandardError => error
                  writeError("File #{inputFilename}, line #{lineNumber}: #{error}.")
               end
            else
               writeError("Error connecting to QuickBase.")
            end
            logout
         else   
            writeError("Input file #{inputFilename} does not exist.")
         end
   end
   
   def writeError(error)
      @errorFile = File.new(@errorFilename,"w") if @errorFilename and @errorFile.nil?
      @errorFile.puts(error) 
   end
   
   def login
      if @username.nil? or @password.nil?
         writeError("Must set username and password") 
      elsif @qbc.nil?
         @qbc = QuickBase::Client.new(@username,@password)
      end
      ret = @qbc and @qbc.requestSucceeded
   end
   
   def logout
      @qbc.signOut if @qbc
      @qbc = nil
   end
   
   def resetTableVars
      @activeRecordNumber = nil
      @activeFieldID = nil
      @activeField = nil
      @fieldIDValues = nil
      @fieldValues = nil
      @fieldType = nil
      @fieldProperties = nil
      @fieldAllowsNewChoices = false
      @fieldIsMultiLineText = false
      @fieldIsValidFileAttachment = false
   end
   
   def setApplication(appName)
      addOrEditRecord
      resetTableVars
      @singleTableApplication = false
      @qbc.findDBByname(appName)
      if @qbc.dbid.nil?
         @qbc.createDatabase(appName,appName)
         raise "Error creating application '#{name}'" if @qbc.dbid.nil?
         raise "Unable to find table '#{@appName}'" if !@qbc.lookupChdbid(@appName)
         @singleTableApplication = true
      end
      raise "Error finding or creating application '#{name}'" if @qbc.dbid.nil?
      @appName = appName
      @qbc._getSchema
      @dbid = @qbc.dbid.dup
   end
   
   def setTable(name)
      addOrEditRecord
      resetTableVars
      if !@singleTableApplication
         raise "Unable to find table '#{name}'" if !@qbc.lookupChdbid(name)
         @qbc._getSchema
      end
      @dbid = @qbc.dbid.dup
   end
   
   def setDBID(id)
      addOrEditRecord
      resetTableVars
      @singleTableApplication = false
      @qbc.getSchema(id)
      raise "Unable to find table with the '#{id}' id" if @qbc.dbid.nil?
      @dbid = @qbc.dbid.dup
   end
   
   def setRecord(number)
      addOrEditRecord
      @activeRecordNumber = number
      @activeRecordNumber = nil if @activeRecordNumber and @activeRecordNumber.length == 0
      if @activeRecordNumber
         @qbc._setActiveRecord(@activeRecordNumber)
      else   
         @qbc.resetrid
      end   
   end
   
   def checkFieldNameAndValue(fieldName,fieldValue)
   
      @fieldNameIsFieldID = false
      @fieldAllowsNewChoices = false
      @fieldIsMultiLineText = false
      @fieldIsValidFileAttachment = false
      @fieldType = nil
      @fieldProperties = nil

      fieldElement = @qbc.lookupField( @qbc.lookupFieldIDByName(fieldName) )
      if !fieldElement and fieldName.match(/[0-9]+/) # if it's a number, see if it's a valid field id
         fieldElement = @qbc.lookupField(fieldName,fieldValue)
         @fieldNameIsFieldID = true if fieldElement
      end
      
      if !fieldElement # field doesn't exist. the field can be created if the value is actually a valid field type
         if fieldValue and fieldValue.length > 0
            fieldValue.strip!
            if fieldValue.length > 0
               fieldTypeAndProperties = fieldValue.split(/ /)
               type = fieldTypeAndProperties[0]
               if @qbc.isValidFieldType?(type)
                  @fieldType = Hash.new if @fieldType.nil?
                  @fieldType[fieldName] = type.dup
                  fieldTypeAndProperties.shift # anything after the field type must be valid field properties in the form property="value"
                  fieldTypeAndProperties.each { |property|
                     propertyType = property[0..(property.index("=")-1)]
                     raise "Invalid field property type #{propertyType}" if !@qbc.isValidFieldProperty?(propertyType) 
                     propertyValue = property[(property.index("=")+1)..(property.rindex("\"")-1)]
                     raise "Missing value for field property #{propertyType}" if propertyValue.nil? or propertyValue.length == 0
                     @fieldProperties = Hash.new if @fieldProperties.nil?
                     propertyAndValuePair = Hash.new
                     propertyAndValuePair[propertyType]=propertyValue
                     @fieldProperties[fieldName] << propertyAndValuePair
                  }
               else
                  raise "Invalid field type #{type}."
               end
            else
               raise "Invalid field name #{fieldName}."
            end
         end
      else 
         # do basic data type check
         type = fieldElement.attributes["field_type"].dup
         raise "Unable to determine data type for #{fieldName} field" if type.nil?
         if fieldValue.length > 0 #any field can be blanked out
            case type
               when "checkbox"
                  if !(fieldValue == "1" or fieldValue == "0")
                     raise "Invalid data '#{fieldValue}' for checkbox field #{fieldName}"
                  end
               when "date"
                  fieldValue.gsub!("/","-")
                  if !fieldValue.match(/[0-9][0-9]\-[0-9][0-9]\-[0-9][0-9][0-9][0-9]/)
                     raise "Invalid data '#{fieldValue}' for date field #{fieldName}"
                  end
               when "duration", "float", "currency", "rating"
                  fieldValue.gsub!(",","")
                  if !fieldValue.match(/[0-9]*\.?[0-9]*/)
                     raise "Invalid data '#{fieldValue}' for field #{fieldName}"
                  end
               when "phone"
                  if !fieldValue.match(/[0-9|\.|x]+/)
                     raise "Invalid data '#{fieldValue}' for phone field #{fieldName}"
                  end
               when "file"
                  if FileTest.exist?(fieldValue)
                     @fieldIsValidFileAttachment = true
                  else
                     raise "Invalid file name '#{fieldValue}' for file attachment field #{fieldName}"
                  end
            end
         end
         # check whether field allows user to add to a choicelist.  
         @fieldAllowsNewChoices = fieldAllowsNewChoices?(fieldElement)
         # check whether field allows mutliple lines.  
         @fieldIsMultiLineText = fieldIsMultiLineText?(fieldElement)
      end
      fieldElement
   end
   
   def fieldAllowsNewChoices?(fieldElement)
      allowsUserChoices = false
      findPropertyBlock = proc { |element|
         if element.is_a?(REXML::Element) and element.name == "allow_new_choices" and element.has_text?
            allowsUserChoices = (element.text == "1")
         end
      }
      @qbc.processChildElements(fieldElement, true, findPropertyBlock)
      allowsUserChoices
   end
   
   def fieldIsMultiLineText?(fieldElement)
      isMultiLineText = false
      findPropertyBlock = proc { |element|
         if element.is_a?(REXML::Element) and element.name == "num_lines" and element.has_text?
            isMultiLineText = (element.text != "1")
         end
      }
      @qbc.processChildElements(fieldElement, true, findPropertyBlock)
      isMultiLineText
   end

   def addField(field,type,properties)
      newFieldID, newfieldLabel = @qbc._addField(field, type)
      if newFieldID
         if properties
            fieldPropertiesToSet = Hash.new
            properties.each{|property|
               property.each{|propertyName,propertyValue| fieldPropertiesToSet[propertyName] = propertyValue }
            }
            @qbc._setFieldProperties(fieldPropertiesToSet,newFieldID)
            @qbc._getSchema
         end
      else
         raise "Error creating new field #{field}"
      end
   end

   def setFieldValue(fieldName, value)
      if checkFieldNameAndValue(fieldName,value)
         if @fieldNameIsFieldID
            @activeFieldID = fieldName
            @activeField = nil
            @fieldIDValues = Hash.new if @fieldIDValues.nil?
            @fieldIDValues[@activeFieldID] = value.dup
            @fieldIDProperties = Hash.new if @fieldIDProperties.nil?
            @fieldIDProperties[@activeFieldID] = { "fieldAllowsNewChoices"=>@fieldAllowsNewChoices, "fieldIsMultiLineText"=>@fieldIsMultiLineText, "fieldIsValidFileAttachment"=>@fieldIsValidFileAttachment }
         else
            @activeField = fieldName
            @activeFieldID = nil
            @fieldValues = Hash.new if @fieldValues.nil?
            @fieldValues[@activeField] = value.dup
            @fieldProperties = Hash.new if @fieldProperties.nil?
            @fieldProperties[@activeField] = { "fieldAllowsNewChoices"=>@fieldAllowsNewChoices,"fieldIsMultiLineText"=>@fieldIsMultiLineText, "fieldIsValidFileAttachment"=>@fieldIsValidFileAttachment }
         end
      elsif @fieldType and @fieldType[fieldName]
         if @fieldProperties and @fieldProperties[fieldName]
            addField(fieldName,@fieldType[fieldName],@fieldProperties[fieldName])
         else
            addField(fieldName,@fieldType[fieldName],nil)
         end
      end
   end
   
   def appendFieldValue(value)
      if value and value.length  > 0
         if @activeField and @fieldProperties[@activeField]["fieldIsMultiLineText"]
            @fieldValues = Hash.new if @fieldValues.nil?
            @fieldValues[@activeField] << "\n"
            @fieldValues[@activeField] << value.dup
         elsif @activeFieldID and @fieldIDProperties[@activeFieldID]["fieldIsMultiLineText"]
            @fieldIDValues = Hash.new if @fieldIDValues.nil?
            @fieldIDValues[@activeFieldID] << "\n"
            @fieldIDValues[@activeFieldID] << value.dup
         end
      end
   end
   
   def addFieldValuePairs
      @qbc.clearFieldValuePairList
      if @fieldValues
         @fieldValues.each{ |f,v|
            if f and v and @fieldProperties and @fieldProperties[f] and @fieldProperties[f]["fieldAllowsNewChoices"]
               @fieldChoicesToSet = Hash.new if @fieldChoicesToSet.nil?
               @fieldChoicesToSet[f] = Array.new if @fieldChoicesToSet[f].nil?
               @fieldChoicesToSet[f] << v 
            end
            if f and v and  @fieldProperties and @fieldProperties[f] and @fieldProperties[f]["fieldIsValidFileAttachment"]
               @qbc.addFieldValuePair(f.dup,nil,v.dup,nil)
            else
               @qbc.addFieldValuePair(f.dup,nil,nil,v.dup)
            end
         }
         @fieldValues = nil
      end
      if @fieldIDValues
         @fieldIDValues.each{ |f,v|
            if @fieldIDProperties and @fieldIDProperties[f] and @fieldIDProperties[f]["fieldAllowsNewChoices"]
               @fieldIDChoicesToSet = Hash.new if @fieldChoicesToSet.nil?
               @fieldIDChoicesToSet[f] << v 
            end
            if @fieldIDProperties and @fieldIDProperties[f] and @fieldIDProperties[f]["fieldIsValidFileAttachment"]
               @qbc.addFieldValuePair(nil,f.dup,v.dup,nil)
            else
               @qbc.addFieldValuePair(nil,f.dup,nil,v.dup)
            end
         }
         @fieldIDValues = nil
      end
      @qbc.fvlist
   end

   def isValidRecord?(addingRecord)
      valid = true
      if addingRecord and @qbc.fields
         # check that all required fields are present
         requiredFieldIDs = Hash.new
         requiredFields = Hash.new
         fieldID = ""
         fieldName = ""
         findRequiredFieldsBlock = proc { |element|
            if element.is_a?(REXML::Element) and element.name == "field"
               fieldID = element.attributes["id"]
            elsif element.is_a?(REXML::Element) and element.name == "label" and element.has_text?
               fieldName = element.text
            elsif element.is_a?(REXML::Element) and element.name == "required" and element.has_text?
               if element.text == "1"
                  requiredFieldIDs[fieldID] = "1" 
                  requiredFields[fieldName] = "1" 
               end
            end
         }
         @qbc.processChildElements(@qbc.fields, false, findRequiredFieldsBlock)
         
         if @fieldValues
            @fieldValues.each{ |f,v| requiredFields[f] = nil if requiredFields[f] }
         end
         if @fieldIDValues
            @fieldIDValues.each{ |f,v| requiredFieldIDs[f] = nil if requiredFieldIDs[f]  }
         end
         missingFields = ""
         requiredFields.each{ |f,v| missingFields << "#{f} " if v } if @fieldValues
         requiredFieldIDs.each{ |f,v| missingFields << "#{f} " if v } if @fieldIDValues
         raise "Required fields are missing: #{missingFields}" if missingFields.length > 0
      end
      valid
   end
   
   def addOrEditRecord
      if @activeRecordNumber
         editRecord
      elsif isValidRecord?(true)
         addRecord
      end
   end

   def addRecord
      if addFieldValuePairs
         addFieldChoices
         @qbc.addRecord(@qbc.dbid, @qbc.fvlist)
      end
   end
   
   def editRecord
      if @activeRecordNumber and addFieldValuePairs
         addFieldChoices
         @qbc.editRecord(@qbc.dbid, @activeRecordNumber, @qbc.fvlist)
         @activeRecordNumber = nil
      end
   end
   
   def addFieldChoices
     if @fieldIDChoicesToSet
       @fieldIDChoicesToSet.each{ |f,choices|
          @qbc._fieldAddChoices(f,choices) 
       }
       @fieldIDChoicesToSet = nil
     end
     if @fieldChoicesToSet
       @fieldChoicesToSet.each{ |f,choices|
          @qbc._fieldNameAddChoices(f,choices) 
       }
       @fieldChoicesToSet = nil
     end
   end
   
   #  Writes all records and all fields from a table to the specified 
   #  outputFilename, in the format specified above, sorted by record ID#.
   #  Since they can't be sent back into QuickBase,  built-in fields are excluded.
   def writeDataFromQuickBase(dbid, outputFilename, errorFilename)
     @errorFilename = errorFilename
      if login
         @qbc.getSchema(dbid)
         if @qbc.dbid and @qbc.requestSucceeded
            @outputFile = File.new(outputFilename,"w")
            @outputFile.puts( "dbid:#{dbid}")
            @isBuitlInField = false
            recordIDs = @qbc.getAllValuesForFields(dbid,["Record ID#"],nil,nil,nil,"3","3")
            if recordIDs
               recordIDs["Record ID#"].each{ |recordID|
                  @outputFile.puts( "record:#{recordID}")
                  @qbc._getRecordInfo(recordID)
                  processFieldDataBlock = proc { |element|
                     if element.is_a?(REXML::Element)
                        if element.name == "fid"
                           @isBuitlInField = element.text.to_i < 6
                        elsif element.name == "name" and !@isBuitlInField
                           @outputFile.print("#{element.text}:")
                        elsif element.name == "type"
                           @outputFieldType = element.text.dup.downcase!
                        elsif element.name == "value"  and !@isBuitlInField
                           outputFieldValue = ""
                           outputFieldValue = element.text.dup if element.has_text?
                           outputFieldValue.gsub!("<BR/>","\n ")
                           outputFieldValue = @qbc.formatFieldValue(outputFieldValue,@outputFieldType)
                           outputFieldValue = "" if outputFieldValue.nil?
                           @outputFile.puts(outputFieldValue)
                        end
                     end
                  }
                  @qbc.processChildElements(@qbc.field_data_list,true,processFieldDataBlock)
               }
               @outputFile.close
            end
         else
            writeError("Invalid dbid #{dbid}.")
         end
         logout
      else
         writeError("Error connecting to QuickBase.")
      end
   end

   def TextData.uploadData(username,password,file)
      td = QuickBase::TextData.new(username,password)
      td.sendDataToQuickBase(file,"textDataUploadErrors.txt")
   end
   
   def TextData.downloadData(username,password,dbid)
      td = QuickBase::TextData.new(username,password)
      td.writeDataFromQuickBase(dbid,"downloadedTextData.txt","textDataDownloadErrors.txt")
   end
   
   # Sends data from file to QuickBase, then overwrites the same 
   # file with data from the last referenced table.  It's best to 
   # use this for synchronizing just one table's data. 
   def TextData.synchDataFile(username,password,file)
      td = QuickBase::TextData.new(username,password)
      td.sendDataToQuickBase(file,"textDataUploadErrors.txt")
      td.writeDataFromQuickBase(td.dbid,file,"textDataDownloadErrors.txt")
   end

end # class TextData

end # module QuickBase

#QuickBase::TextData.uploadData(ARGV[0],ARGV[1],ARGV[2]) if ARGV[2]
#QuickBase::TextData.downloadData(ARGV[0],ARGV[1],ARGV[3]) if ARGV[3]
