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
require 'tk'

module QuickBase

# This class maintains a list of QuickBase table changes to watch
# for, how to be notified of the changes, how frequently to check for the
# changes and when to start and stop checking.  It can stop checking
# after a specific number of checks, or stop checking after a specific
# number of successful checks. It can also check for records changes
# that only meet certain conditions.
class EventNotifier

   attr_reader :qbc
   attr_writer  :qbc
   
   def initialize(qbc=nil, username=nil,password=nil)
      @username,@password = username,password
      if qbc
         @qbc = qbc
      elsif @username and @password 
         @qbc = QuickBase::Client.new(@username,@password)
      end   
      @eventNotifications = Array.new
   end
  
   # In addition to a basic record add/modify/delete events,
   # check these conditions before sending a notification. 
   class RecordCondition
   
      # fieldName: field to test, e.g. "Date"
      # logicalOperator: kind of test, e.g. "OAF"
      # fieldValue: value to test for, e.g. "12/31/2006"
      def initialize(fieldName,logicalOperator,fieldValue)
         @fieldName,@logicalOperator,@fieldValue=fieldName,logicalOperator,fieldValue
      end
   
      def validate(qbc,dbid)
         if qbc.lookupFieldIDByName(@fieldName)
            fieldType = qbc.lookupFieldTypeByName(@fieldName)
            if fieldType
               queryOperator = qbc.verifyQueryOperator(@logicalOperator,fieldType)
               if queryOperator.nil? or queryOperator.length == 0
                  raise "Invalid query operator '#{@logicalOperator}' for field '#{@fieldName}' in table #{dbid}"
               else
                  if @fieldValue.length > 0 #any field can be blanked out
                     case fieldType
                        when "checkbox"
                           if !(@fieldValue == "1" or @fieldValue == "0")
                              raise "Invalid data '#{@fieldValue}' for checkbox field #{@fieldName}"
                           end
                        when "date"
                           fieldValue.gsub!("/","-")
                           if !fieldValue.match(/[0-9][0-9]\-[0-9][0-9]\-[0-9][0-9][0-9][0-9]/)
                              raise "Invalid data '#{@fieldValue}' for date field #{@fieldName}"
                           end
                        when "duration", "float", "currency", "rating"
                           fieldValue.gsub!(",","")
                           if !fieldValue.match(/[0-9]*\.?[0-9]*/)
                              raise "Invalid data '#{@fieldValue}' for field #{@fieldName}"
                           end
                        when "phone"
                           if !fieldValue.match(/[0-9|\.|x]+/)
                              raise "Invalid data '#{@fieldValue}' for phone field #{@fieldName}"
                           end
                        when "file"
                           if FileTest.exist?(fieldValue)
                              @fieldIsValidFileAttachment = true
                           else
                              raise "Invalid file name '#{@fieldValue}' for file attachment field #{@fieldName}"
                           end
                     end
                  end
               end
            else
               raise "Unable to validate field type for field '#{@fieldName}' in table #{dbid}"
            end
         else
            raise "Unable to validate field '#{@fieldName}' in table #{dbid}"
         end
         true
      end
      
   end
   
   # A record is added/modified/deleted from a table
   class TableEvent

      attr_reader :url

      def initialize(table, eventType=["recordAdded","recordModified"],application=nil,recordCondition=nil)           
         if eventType.is_a?(String) 
            validateEventType(eventType)
         elsif eventType.is_a?(Array) 
            eventType.each{|et| validateEventType(et)  }
         end
         @table,@eventType,@application,@recordCondition=table,eventType,application,recordCondition
         @lastModifiedTime = 0
         @lastRecModTime = 0
         @numRecords = 0
         @url = "http://www.quickbase.com"
      end
      
      def validateEventType(eventType)
         if @validEventTypes.nil?
            @validEventTypes = Array.new
            @validEventTypes << "recordAdded"
            @validEventTypes << "recordModified"
            @validEventTypes << "recordDeleted"
         end
         if ! (eventType.is_a?(String) and @validEventTypes.include?(eventType))
            raise "Invalid event type '#{eventType}'."
         end
      end
      
      def isEventType?(type)
         ret=false
         if @eventType.is_a?(String) 
            ret = @eventType == type
         elsif @eventType.is_a?(Array) 
            @eventType.each{|et| 
               if et == type
                  ret = true
                  break
               end
            }
         end
         ret
      end
      
      def validateApplicationAndTable(qbc)
         if @application and @application.length > 0
            @table = @application if @table.nil?
            qbc.findDBByName(@application)
            if qbc.requestSucceeded
               qbc.lookupChdbid(@table)
               if qbc.requestSucceeded
                  @dbid = qbc.dbid.dup
                  qbc._getSchema
                  @tablename = @table.dup
               end
            end
         elsif @table and @table.length > 0
            qbc.getSchema(@table)
            if qbc.requestSucceeded
               @dbid = qbc.dbid.dup
               @tableName = qbc.getResponseElement( "table/name" ).text
            end   
         else
            raise "table and/or application must be specified"
         end
         raise "Error retrieving schema for table #{@table}" if @dbid.nil?
         @url = "https://www.quickbase.com/db/#{@dbid}"
         @dbid
      end

      def validateRecordCondition(qbc)
         if @recordCondition
            if @recordCondition.is_a?(RecordCondition)
               @recordCondition.validate(qbc,@dbid)
            elsif @recordCondition.is_a?(Array)
               @recordCondition.each{|rc|
                  if rc.is_a?(RecordCondition)
                     rc.validate(qbc,@dbid)
                  else
                     raise "recordcondition must be a RecordCondition or Array of RecordConditions"
                  end
               }
            else
               raise "recordcondition must be a RecordCondition or Array of RecordConditions"
            end
         end
         true
      end
      
      def validate(qbc)
         if validateApplicationAndTable(qbc)
            validateRecordCondition(qbc)
         end
         true
      end
      
      def eventOccurred?(qbc)
         query = ""
         ret = false
         qbc.getDBInfo(@dbid)
         if qbc.requestSucceeded
            if @lastModifiedTime > 0 and qbc.lastModifiedTime.to_i > @lastModifiedTime
               if isEventType?("recordModified")
                  if qbc.lastRecModTime.to_i > @lastRecModTime
                     query = "{'2'.GT.'#{@lastRecModTime}'}"
                  end
               end
               if isEventType?("recordAdded")
                  if qbc.numRecords.to_i > @numRecords
                     if query.length > 0
                        query << "OR{'1'.GT.'#{@lastModifiedTime}'}"
                     else
                        query = "{'1'.GT.'#{@lastModifiedTime}'}"
                     end
                  end
               end
               if isEventType?("recordDeleted")
                  if qbc.numRecords.to_i < @numRecords
                     ret = true
                  end
               end
               #puts query
               if query.length > 0
                  @records = qbc.getAllValuesForFields(@dbid, "Record ID#", query, nil, nil, "3")
                  puts "Found #{@records.length} records."
                  ret = @records.length > 0
               end
            end
            @numRecords = qbc.numRecords.to_i
            @lastModifiedTime = qbc.lastModifiedTime.to_i
            @lastRecModTime = qbc.lastRecModTime.to_i
         else
            raise "Error getting information for table #{@dbid}"
         end
         ret
      end
      
      def tableEventNotificationMessage
         message = "Records have been "
         if isEventType?("recordAdded")
            eventTypeMessage = "added"
         else         
            eventTypeMessage = ""
         end
         if isEventType?("recordModified")
            if eventTypeMessage.length > 0 
               eventTypeMessage << " or modified"
            else
               eventTypeMessage = "modified"
            end
         end
         if isEventType?("recordDeleted")
            if eventTypeMessage.length > 0 
               eventTypeMessage << "or deleted"
            else
               eventTypeMessage = "deleted"
            end
         end
         message << eventTypeMessage
         message << " in the '#{@tableName}' QuickBase table."
         return @tableName,message
      end
   
   end
   
   # Frequency and start/stop time of checking for TableEvent
   class EventCheckPolicy
      
      attr_reader :interval, :starttime, :stoptime, :nextCheckTime, :numChecks, :numSuccessfulChecks
      
      # interval: minutes between checks
      # starttime: start checking at this time
      # stoptime: stop checking at this time
      # numChecks: check this number of times then stop
      # numSuccessfulChecks: stop checking after changes found this number of times
      def initialize(interval=nil,starttime=nil,stoptime=nil,numChecks=-1,numSuccessfulChecks=-1 )
         if interval
            if interval.is_a?(Integer) and interval > 0
               @interval = interval * 60
            else
               raise "interval is not a positive number"
            end
         else   
            @interval = 1 * 60
         end
         if starttime 
            if starttime.is_a?(Time)
               @starttime = starttime
            else
               raise "starttime must be a Time object"
            end
         else
            @starttime = Time.now
         end   
         if stoptime and !stoptime.is_a?(Time)
            raise "stoptime must be a Time object"
         end
         @stoptime = stoptime
         if @starttime and @stoptime and @starttime > @stoptime
            raise "starttime must be before stoptime"
         end
         @numSuccessfulChecks = numSuccessfulChecks
         if @numSuccessfulChecks.nil?
            @numSuccessfulChecks = -1 
         elsif !@numSuccessfulChecks.is_a?(Integer)
            raise "numSuccessfulChecks must be a number"
         end
         if @numSuccessfulChecks > 0
            @numChecks = -1
         else
            @numChecks = numChecks
            if @numChecks.nil?
               @numChecks = -1 
            elsif !@numChecks.is_a?(Integer)
               raise "numChecks must be a number"
            end
         end
         setNextCheckTime(true)
      end
      
      def setNextCheckTime(initializing=false,checkSucceeded=false)
         if @nextCheckTime
            @nextCheckTime += @interval
         else
            @nextCheckTime = @starttime + @interval
         end
         if checkSucceeded and @numSuccessfulChecks > 0
            @numSuccessfulChecks  = @numSuccessfulChecks  - 1
         end
         @stopChecking = true if @numSuccessfulChecks == 0
         if !initializing and @numChecks > 0
            @numChecks = @numChecks - 1
            @stopChecking = true if @numChecks == 0
         end
         if !@stopChecking
            @stopChecking = (@stoptime and @nextCheckTime > @stoptime)
         end
      end
      
      def stopChecking?
         @stopChecking
      end
   end
   
   # What to do when a TableEvent has occurred
   class Notification
   
      attr_reader :beep, :message, :title, :launchBrowser
   
      def initialize(beep=true,message="A QuickBase event has occurred.",title="QuickBase Event",launchBrowser=true)
         if beep or message
            @beep = beep
            @message = message
            @message = "" if @message.nil?
            @title = title
            @title = "" if @title.nil?
            @launchBrowser = launchBrowser
         else
            raise "Notification must be a beep and/or a message" 
         end
      end
      
      def overrideDefaultTitleAndMessage(title,withThis)
         if @message == "A QuickBase event has occurred."
            @message = withThis
            @title = title
         end
         return @title,@message
      end

   end
   
   # Event, notification, and checking policy
   class EventNotification
   
      attr_reader :notification
      
      def initialize(tableEvent, notification=nil, eventCheckPolicy=nil)
         if tableEvent and tableEvent.is_a?(TableEvent)
            @tableEvent,@notification,@eventCheckPolicy=tableEvent,notification,eventCheckPolicy
            @notification = Notification.new if @notification.nil?
            @eventCheckPolicy = EventCheckPolicy.new if @eventCheckPolicy.nil?
         else
            raise "tableEvent must be TableEvent" 
         end
      end
      
      def method_missing(method, *args)
         if method == :nextCheckTime
            @eventCheckPolicy.nextCheckTime
         elsif method == :setNextCheckTime
            @eventCheckPolicy.setNextCheckTime(args[0],args[1])
         elsif method == :stopChecking?
            @eventCheckPolicy.stopChecking?
         elsif method == :numChecks
            @eventCheckPolicy.numChecks
         elsif method == :numSuccessfulChecks
            @eventCheckPolicy.numSuccessfulChecks
         elsif method == :eventOccurred?
            @tableEvent.eventOccurred?(@qbc)
         elsif method == :url
            @tableEvent.url
         elsif method == :tableEventNotificationMessage
            @tableEvent.tableEventNotificationMessage
         else
            super.method_missing(method)
         end
      end

      def validate(qbc)
         if qbc and qbc.is_a?(QuickBase::Client)
            @tableEvent.validate(qbc)
            @qbc = qbc
         else
            raise "qbc must be an instance of QuickBase::Client"
         end
         true
      end
      
   end # class EventNotification
   
   def addEventNotification(eventNotification)
      @eventNotifications << eventNotification if eventNotification.validate(@qbc)
   end
   
   # Call with a block to run code when an event occurs, or 
   # call without a block to show a message and/or beep.
   # The loop stops if all event checks are beyond their stop time.
   def startChecking
      startTime = Time.now
      firstLoop = true
      loop {
         timeNow = Time.now
         stopChecking = true
         @eventNotifications.each { |eventNotification|
            unless eventNotification.stopChecking?
               stopChecking = false
               title,message=eventNotification.tableEventNotificationMessage
               if timeNow > eventNotification.nextCheckTime
                  puts "Checking for changes in QuickBase. (#{title} - #{timeNow})"
                  checkSucceeded = false
                  if eventNotification.eventOccurred?
                     checkSucceeded = true
                     if block_given?
                        yield eventNotification
                     else
                        eventNotification.notification.overrideDefaultTitleAndMessage(title,message)
                        notify(eventNotification.notification,eventNotification.url)
                     end
                  end
                  eventNotification.setNextCheckTime(false,checkSucceeded)
                  unless eventNotification.stopChecking?
                     checkTimeMessage = "Next check time for '#{title}' will be #{eventNotification.nextCheckTime}." 
                     if eventNotification.numSuccessfulChecks > 0
                        checkTimeMessage << " (#{eventNotification.numSuccessfulChecks } more successful checks will be performed)."
                     elsif eventNotification.numChecks > 0
                        checkTimeMessage << " (#{eventNotification.numChecks} more checks will be performed)."
                     end
                     puts checkTimeMessage
                  end
               elsif firstLoop
                  checkTimeMessage = "Next check time for '#{title}' will be #{eventNotification.nextCheckTime}." 
                  puts checkTimeMessage
               end   
            end
         }
         firstLoop = false
         break if stopChecking
      }
   end
   
   # Event occurred: beep and/or show a message on separate thread
   def notify(notification,url)
         Tk.bell if notification.beep
         if notification.message
            showMessage(notification.title,notification.message,url,notification.launchBrowser)
         end
   end
   
   def showMessage(messageTitle,message,url,launchBrowser)
   
      message = "#{message}\n\nLaunch QuickBase?" if url and launchBrowser
      
      root = TkRoot.new{ title messageTitle }
      frame = TkFrame.new(root){
          pack "side" => "top"
          borderwidth 8 
      }
      messageLabel = TkLabel.new(frame){
          text message
          font "Arial 10 bold"
          pack "side"=>"top"
      }
       if url and launchBrowser      
         buttonFrame = TkFrame.new(frame){
             pack "side" => "bottom"
             width 50 
         }
         yesButton = TkButton.new(buttonFrame){
             text "Yes" 
             font "Arial 10 bold"
             pack "side"=>"left", "padx"=>5, "pady"=>5
         }
         yesButton.command { 
            launchURL(url) 
            Tk.exit
         }
         noButton = TkButton.new(buttonFrame){
             text "No" 
             font "Arial 10 bold"
             pack "side"=>"right","padx"=>5, "pady"=>5
         }
         noButton.command { Tk.exit }
      else
         okButton = TkButton.new(frame){
             text "OK" 
             font "Arial 10 bold"
             pack "side"=>"bottom"
         }
         okButton.command { Tk.exit }
      end
      Tk.mainloop
      Tk.restart
   end

   def launchURL(url)
      url.gsub!("&","^&")
      url = "start #{url}" if RUBY_PLATFORM.split("-")[1].include?("mswin")  
      if !system(url)
         message = "Error launching browser at #{url}."
         Tk.messageBox({"icon"=>"error","title"=>"QuickBase Event Notifier", "message" => message})      
      end
   end
   
   # Simple method to get messages when records are added or modified in a table
   def EventNotifier.watch(username,password,dbid)
      en = EventNotifier.new(nil,username,password)
      notification = EventNotification.new(TableEvent.new(dbid))
      en.addEventNotification(notification)
      en.startChecking
   end

   # Simple method to run code when records are added or modified in a table
   def EventNotifier.watchAndRunCode(username,password,dbid)
      en = EventNotifier.new(nil,username,password)
      notification = EventNotification.new(TableEvent.new(dbid))
      en.addEventNotification(notification)
      en.startChecking { |eventNotification| 
         yield eventNotification 
      }
   end

   # Simple method to check one time only, 15 minutes from now, then stop
   def EventNotifier.checkOnce(username,password,dbid)
      en = EventNotifier.new(nil,username,password)
      notification = EventNotification.new(TableEvent.new(dbid),nil,EventCheckPolicy.new(15,nil,nil,1))
      en.addEventNotification(notification)
      en.startChecking
   end
   
   # Simple method to wait for one QuickBase change then stop
   def EventNotifier.waitOnce(username,password,dbid)
      en = EventNotifier.new(nil,username,password)
      notification = EventNotification.new(TableEvent.new(dbid),nil,EventCheckPolicy.new(nil,nil,nil,nil,1))
      en.addEventNotification(notification)
      en.startChecking
   end

   # Simple method to check for records created after 2006 and modified today 
   def EventNotifier.watch2007Changes(username,password,dbid)
      en = EventNotifier.new(nil,username,password)
      rc = RecordCondition.new("Date Created", "OAF", "01-01-2007") 
      te = TableEvent.new(dbid,"recordModified",nil,rc)
      notification = EventNotification.new(te)
      en.addEventNotification(notification)
      en.startChecking
   end

end #class EventNotifier

end #module QuickBase

#if ARGV[2] and ARGV[2] == "watchCommunityForum"
#   QuickBase::EventNotifier.watch(ARGV[0],ARGV[1],"bbqm84dzy") 
#elsif ARGV[2] == "watchDBID" and ARGV[3] and ARGV[3].length > 0 
#   QuickBase::EventNotifier.watch(ARGV[0],ARGV[1],ARGV[3]) 
#elsif ARGV[2] == "checkDBIDOnce" and ARGV[3] and ARGV[3].length > 0 
#   QuickBase::EventNotifier.checkOnce(ARGV[0],ARGV[1],ARGV[3]) 
#elsif ARGV[2] == "waitDBIDOnce" and ARGV[3] and ARGV[3].length > 0 
#   QuickBase::EventNotifier.waitOnce(ARGV[0],ARGV[1],ARGV[3]) 
#elsif ARGV[2] == "watch2007Changes" and ARGV[3] and ARGV[3].length > 0 
#  QuickBase::EventNotifier.watch2007Changes(ARGV[0],ARGV[1],ARGV[3]) 
#end
