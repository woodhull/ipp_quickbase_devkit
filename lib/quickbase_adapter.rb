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

require 'rubygems'
require 'WorkPlaceClient'
require 'QuickBaseClient'

module ActiveRecord

   # Add the QuickBase connection to ActiveRecord
   class Base
      def self.quickbase_connection(config)
         config = config.symbolize_keys
         username = config[:username] 
         password = config[:password] 
         if config.has_key?(:database)
           database = config[:database]
         else
           raise ArgumentError, "No database specified. Missing argument: database."
         end
         if config[:useWorkPlace]
           @qbc = QuickBase::WorkPlaceClient.new(username,password)
         else
           @qbc = QuickBase::Client.init("username" => username, "password" => password, "org" => config[:organization], "apptoken" => config[:token])
           #@qbc = QuickBase::Client.new(username,password)
         end  
         if @qbc.findDBByName(database)
            @qbc._getSchema
         elsif !@qbc.getSchema(database)
           raise ArgumentError, "Database '#{database}' is not accessible."
         end
         if config[:printRequestsAndResponses]
            @qbc.printRequestsAndResponses = config[:printRequestsAndResponses]
         end
         if config[:cacheSchemas]
              @qbc.cacheSchemas = config[:cacheSchemas]
         end
         ConnectionAdapters::QuickBaseAdapter.new(@qbc,nil,config)
      end
   end

   module ConnectionAdapters
   
      # Rails-friendly definition of a QuickBase column
      class QuickBaseColumn < Column 
         attr_accessor :quickBaseFieldAttributes 
         
         def initialize(fieldAttributes)
            @quickBaseFieldAttributes = fieldAttributes
            super(@quickBaseFieldAttributes ["columnName"],@quickBaseFieldAttributes["default_value"],fieldType())
            primary = @quickBaseFieldAttributes["primary"] 
            @quickBaseFieldAttributes["decimalPrecision"] ||= "38"
         end
         
         def name
            @name.downcase.gsub( /\W/, "_" )
         end
         
         def human_name
            @quickBaseFieldAttributes["quickBaseFieldName"]
         end
         private
         
         def fieldType
            ret = "string"
            case @quickBaseFieldAttributes["quickBaseFieldType"]
               when "checkbox" then ret = "boolean"
               when "currency" then ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},2)"
               when "dblink" then ret = "string"
               when "date" then ret = "date"
               when "duration" then ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},0)"
               when "email" then ret = "string"
               when "file" then ret = "blob"
               when "fkey" then ret = "string"
               when "float"  
                  if @quickBaseFieldAttributes["decimal_places"]
                     ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},#{@quickBaseFieldAttributes['decimal_places']})"
                  else   
                     ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},0)"
                  end
               when "formula" then ret = "string"
               when "lookup" then ret = "string"
               when "phone"  then ret = "string"
               when "rating"  
                  ret =  "int(1)"
               when "recordid"  then ret = "int"
               when "text"  then ret = "text"
               when "timeofday"  then ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},0)"
               when "timestamp"  then ret = "datetime"
               when "url"  then ret = "string"
               when "userid" then ret = "decimal(#{@quickBaseFieldAttributes['decimalPrecision']},0)"
            end
            ret
         end
      end
   
      # The QuickBase Adapter for Rails
      class QuickBaseAdapter < AbstractAdapter
      
         def initialize(connection, logger, connection_options=nil)
           super(connection, logger)
           @connection_options = connection_options
           @qbc = @connection
           @main_dbid = @qbc.dbid.dup
           @main_dbname = @qbc.dbname.dup.downcase
           @id_field_name = "Record ID#"
           @id_fid = "3"
           @useActiveTableColumns = false
           @cachedColumns = {}
         end
         
         def adapter_name
           'QuickBase'
         end
         
         def columns(table_name, name = nil)
         
            return [] if table_name.nil? or table_name.blank?
            
            if @useActiveTableColumns
               dbid = @qbc.dbid
               @useActiveTableColumns = false
            else
               @qbc.getSchema(@main_dbid)
               if table_name.downcase != @main_dbname or @qbc.chdbids
                  dbid = @qbc.lookupChdbid(table_name)
                  @qbc.getSchema(dbid)
               end
            end
            
            if @qbc.cacheSchemas and @cachedColumns[dbid]
               quickBaseColumns = @cachedColumns[dbid]
            else
               quickBaseColumns = []
               columnNames = @qbc.getFieldNames(dbid)
               key_fid = @qbc.key_fid
               primary = false
               columnNames.each{|columnName|
               
                  fieldAttributes = {}
                  quickBaseFieldId = @qbc.lookupFieldIDByName(columnName)
                  quickBaseFieldType = @qbc.lookupFieldTypeByName(columnName)
                  
                  fieldAttributes["quickBaseFieldName"] =  columnName.dup
                  fieldAttributes["quickBaseFieldId"] =  quickBaseFieldId.dup
                  fieldAttributes["quickBaseFieldType"] =  quickBaseFieldType.dup
                  fieldAttributes["default_value"] =  @qbc.lookupFieldPropertyByName(columnName, "default_value" )
                  fieldAttributes["decimal_places"] =  @qbc.lookupFieldPropertyByName(columnName, "decimal_places" )
                  
                  if key_fid and key_fid == quickBaseFieldId
                     fieldAttributes["primary"] =  true
                  elsif quickBaseFieldType == "recordid"
                     @id_field_name = columnName.dup 
                     @id_fid = quickBaseFieldId.dup
                     columnName = "id"
                  elsif quickBaseFieldId.to_i < 6  
                     columnName << "_id" 
                  end
                  fieldAttributes["columnName"] =  columnName.dup
                  quickBaseColumn = QuickBaseColumn.new(fieldAttributes)
                  quickBaseColumns << quickBaseColumn
               }
               if @qbc.cacheSchemas
                  @cachedColumns[dbid] = quickBaseColumns
               end
            end
            quickBaseColumns
         end
         
         def quote_column_name(name)
           "[#{name}]"
         end
         
         def quote(value, column = nil)
            ret = value ? "'#{value}'" : ''
         end
         
         def insert(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
           sql.gsub!("NULL,","'',")
           @qbc.doSQLInsert(sql)
         end
   
         def update(sql, name = nil)
            selectString = sql.dup
            selectString.gsub!("[id]",@id_fid) 
            @qbc.doSQLUpdate(selectString)
         end
         
         def delete(sql, name = nil)
            selectString = sql.dup
            selectString.gsub!("DELETE","SELECT [id] ")
            selectString.gsub!("[id]",@id_fid)
            rows = select(selectString,name)
            rows.each{|row|
               recordID = row["id"]
               @qbc._deleteRecord(recordID) if recordID
            }
         end
         
         def select(sql,name)
            puts sql
            sql = sql.to_s
            
            if sql.match(/([^:]+)(:)(.+)/)
               table = $1
               sql = $3
            elsif name  
               table = name.split()[0]
            end
            
            rows = nil
            if sql.include?("SELECT count(*)")
               rows = []
               rows << {"count" => @qbc.doSQLQuery(sql).to_i }
            elsif sql.include?("SELECT ")
               sql.gsub!(".id",".#{@id_field_name}")
               rows = @qbc.doSQLQuery(sql, :Array)
               rows.each{|row| row["id"] = row[@id_field_name]} if rows
            elsif sql.match(/\{[^\}]+\}/)  # QuickBase query 
               setActiveTable(table)
               rows = @qbc.getAllValuesForFieldsAsArray(@qbc.dbid,@qbc.getFieldNames,sql)            
               rows.each{|row| row["id"] = row[@id_field_name]} if rows
            elsif sql.length > 0 # named QuickBase query 
               setActiveTable(table)
               rows = @qbc.getAllValuesForFieldsAsArray(@qbc.dbid,nil,nil,nil,sql)            
               rows.each{|row| row["id"] = row[@id_field_name]} if rows
            end
            puts rows.inspect
            
            rows
            
         end
         
         def setActiveTable(table)
            if table
               foundTable  = false
               save_dbid = @qbc.dbid.dup
               @qbc.getSchema(@main_dbid)
               if table.downcase != @main_dbname
                  if @qbc.lookupChdbid(table)
                     if @qbc._getSchema
                        foundTable  = true
                     end
                  elsif @qbc.findDBByname(table)                      
                     if @qbc._getSchema
                        foundTable  = true
                     end
                  else
                     if @qbc.getSchema(table)
                        foundTable  = true
                     end
                  end
               end
               if foundTable
                  @useActiveTableColumns = true
               else
                  @qbc.getSchema(save_dbid)
               end
            end
            @qbc.dbid
         end
   
         def execute(sql, name = nil)
           if sql and sql.is_a?(String) and sql.length > 0
              @qbc.instance_eval(sql)
           end
         end
         
         def supports_count_distinct?
           false
         end
         
         def active?
           @qbc.ticket
         end

         def reconnect!
             @qbc.signOut
             @qbc.authenticate(@qbc.username,@qbc.password) 
             @active = !@qbc.ticket.nil?
         end

         def disconnect!
           @qbc.signOut 
           @active = @qbc.ticket
         end

         def create_table(name, options = {})
           raise NotImplementedError, "create_table is not supported by the QuickBase adapter"
         end
         
         def add_column(table_name, column_name, type, options = {})
           raise NotImplementedError, "add_column is not supported by the QuickBase adapter"
         end
         
         def remove_column(table_name, column_name)
           raise NotImplementedError, "remove_column is not supported by the QuickBase adapter"
         end
         
         def add_index(table_name, column_name, options = {})
           raise NotImplementedError, "indexing is not supported by the QuickBase"
         end
          
         def index_name(table_name, options) #:nodoc:
           raise NotImplementedError, "indexing is not supported by the QuickBase"
         end

      end # class QuickBaseAdapter
   end # module ConnectionAdapters
end # module ActiveRecord
