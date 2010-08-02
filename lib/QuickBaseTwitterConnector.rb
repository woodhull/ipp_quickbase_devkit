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
gem 'twitter4r', '>=0.3.0'
require 'twitter'

require 'QuickBaseClient'

module QuickBase

  class TwitterConnector
    
    #----------------------------------------------------------------
    def initialize(options = {:get_friends_twitter_status => true,:get_direct_messages => true})
      @options = options
      [quickbase_username,quickbase_password,twitter_username,twitter_password].each{|option|
        @options[option] ||= get_input(option)
      }
      get_connection_type
      find_or_create_twitter_databases if get_quickbase_client
      run if get_twitter_client
    end
    
    private
    
    #----------------------------------------------------------------
    def get_input(string)
      ret = ""
      while ret.length == 0
        print "Please enter the #{string} to use for this session: "
        ret = gets.chop
      end
      ret
    end
    
    #----------------------------------------------------------------
    def get_quickbase_client
      begin
        @qbc = QuickBase::Client.new(@options[quickbase_username],@options[quickbase_password])
        #@qbc.printRequestsAndResponses=true
      rescue StandardError => error
        puts "Error accessing QuickBase.  Please check your username and password. (#{error})"
        @qbc= nil
      end
      @qbc
    end  
    
    #----------------------------------------------------------------
    def get_twitter_client
      begin
        @tc = Twitter::Client.new(:login => @options[twitter_username],:password => @options[twitter_password])
      rescue StandardError => error
        puts "Error accessing Twitter.  Please check your username and password. (#{error})"
        @tc= nil
      end
      @tc
    end  
    
    #----------------------------------------------------------------
    def get_connection_type
      puts "\n\nPlease enter a number to select the connection type:\n\n"
      puts "1 - Send Twitter messages to QuickBase."
      puts "2 - Send QuickBase messages to Twitter."
      puts "3 - Exchange messages between QuickBase and Twitter."
      puts "4 - Send automated replies from QuickBase to Twitter."
      puts "5 - All the above.\n\n"
      @options[connection_type] = ""
      while !["1","2","3","4","5"].include?(@options[connection_type])
        @options[connection_type] = gets.chop
      end
      puts "\n\n"
    end  
    
    #----------------------------------------------------------------
    def find_or_create_twitter_databases
      message_database = "Twitter messages: #{@options[quickbase_username]} - #{@options[twitter_username]}"
      @messages_dbid = @qbc.findDBByName(message_database)
      if @messages_dbid.nil?
        begin
          @messages_dbid = @qbc.createDatabase(message_database, "Messages exchanged between QuickBase (#{@options['QuickBase username']}) and Twitter (#{@options['Twitter username']})." )
          @qbc.addField(@messages_dbid, message_type, "text")
          @qbc.addField(@messages_dbid, twitter_username, "text")
          @qbc.addField(@messages_dbid, received_from_twitter, "text")
          @qbc.addField(@messages_dbid, keyword, "text")
          @qbc.addField(@messages_dbid, send_to_twitter, "text")
          @qbc.addField(@messages_dbid, sent_to_twitter, "checkbox")
        rescue StandardError => error
          puts "Error creating Twitter messages database in QuickBase. (#{error})"
        end
      end  
      @qbc.getSchema(@messages_dbid)
      @messages_dbid = @qbc.lookupChdbid(message_database)
      @qbc.getSchema(@messages_dbid)
      @fieldIDs = {}
      @qbc.getFieldNames.each{|name|@fieldIDs[name]=@qbc.lookupFieldIDByName(name)}
    end  
    
    #----------------------------------------------------------------
    def run
      @lastCheckTime = (Time.now-60)
      loop {
        nextCheckTime = Time.now
        if ["1","3","5"].include?(@options[connection_type])
          if @options[:get_my_twitter_status]
            get_my_twitter_status 
            sleep(60)
          end
          if @options[:get_friends_twitter_status]
            get_friends_twitter_status 
            sleep(60)
          end
          if @options[:get_direct_messages]
            get_direct_messages 
            sleep(60)
          end
        end
        if ["2","3","5"].include?(@options[connection_type])
          send_messages_to_twitter
          sleep(60)
        end
        if ["4","5"].include?(@options[connection_type])
          get_direct_messages 
          sleep(60)
        end
          
        @lastCheckTime = nextCheckTime
      }
    end
    
    #----------------------------------------------------------------
    def get_my_twitter_status
      get_twitter_status(:me)
    end  
    
    #----------------------------------------------------------------
    def get_friends_twitter_status
      get_twitter_status(:friends)
    end  

    #----------------------------------------------------------------
    def get_public_twitter_status
      get_twitter_status(:public)
    end  

    #----------------------------------------------------------------
    def get_twitter_status(who,twitter_options = {})
      twitter_options["since"] ||= @lastCheckTime
      puts "Getting '#{who}' Twitter Status since #{twitter_options["since"]}."
      begin
        @tc.timeline_for(who,twitter_options) {|status|
          @qbc.clearFieldValuePairList
          @qbc.addFieldValuePair(twitter_username,nil,nil,status.user.screen_name)
          @qbc.addFieldValuePair(received_from_twitter,nil,nil,status.text)
          @qbc.addFieldValuePair(message_type,nil,nil,"status")
          @qbc.addRecord(@messages_dbid,@qbc.fvlist)
          puts "Twitter status added to QuickBase: #{status.user.screen_name}: #{status.text}"
        }
      rescue Twitter::RESTError => error 
        #puts "Twitter exception handling timeline_for request: #{error}"
      rescue StandardError => error
        puts "Exception handling timeline_for request: #{error}"
      end
    end
    
    #----------------------------------------------------------------
    def get_direct_messages(twitter_options = {})
      twitter_options["since"] ||= @lastCheckTime 
      puts "Getting Direct Messages from Twitter since #{twitter_options["since"]}."
      begin
        received_messages = @tc.messages(:received,twitter_options)
        if received_messages
          received_messages.each{|message|
            if message.created_at > @lastCheckTime
              sentAutomatedReply = false
              if ["4","5"].include?(@options[connection_type])
                if message.text[-1,1] == ':' 
                  sentAutomatedReply = sendAutomatedReplyFromQuickBase(message.text,message.sender.screen_name)
                else
                  sentAutomatedReply = processRESTRequest(message.text,message.sender.screen_name)
                end
              end  
              if !sentAutomatedReply
                @qbc.clearFieldValuePairList
                @qbc.addFieldValuePair(twitter_username,nil,nil,message.sender.screen_name)
                @qbc.addFieldValuePair(received_from_twitter,nil,nil,message.text)
                @qbc.addFieldValuePair(message_type,nil,nil,"message")
                @qbc.addRecord(@messages_dbid,@qbc.fvlist)
                puts "Twitter Direct Message added to QuickBase: #{message.sender.screen_name}: #{message.text}"
              end
            end
          }
        end  
      rescue Twitter::RESTError => error 
        puts "Twitter exception handling Twitter::Client.messages request: #{error}"
      rescue StandardError => error
        puts "Exception handling Twitter::Client.messages request: #{error}"
      end
    end  
    
    #----------------------------------------------------------------
    def send_messages_to_twitter
      timeToCompare = Misc.time_in_milliseconds(@lastCheckTime)
      puts "Sending messages from QuickBase to Twitter added since #{@lastCheckTime}."
      @qbc.iterateRecords(@messages_dbid,[date_created,record_ID,send_to_twitter,twitter_username],"{'1'.OAF.'today'}AND{'#{@fieldIDs[send_to_twitter]}'.XEX.''}AND{'#{@fieldIDs[sent_to_twitter]}'.XEX.'1'}"){|new_quickbase_record|
        if new_quickbase_record[date_created].to_i > timeToCompare 
          begin
            msgType = ""     
            recipient = ""          
            if new_quickbase_record[twitter_username]
              msgType = "Direct Message"
              recipient = new_quickbase_record[twitter_username].dup
              Twitter::Message.create(:text => new_quickbase_record[send_to_twitter].dup,:recipient => new_quickbase_record[twitter_username].dup,:client => @tc)
            else  
              msgType = "Status"
              Twitter::Status.create(:text => new_quickbase_record[send_to_twitter].dup,:client => @tc)
            end
            @qbc.clearFieldValuePairList
            @qbc.addFieldValuePair(sent_to_twitter,nil,nil,"1")
            @qbc.editRecord(@messages_dbid,new_quickbase_record[record_ID],@qbc.fvlist)
            puts "#{msgType} sent from QuickBase to Twitter: #{recipient} #{new_quickbase_record[send_to_twitter].dup}"
          rescue Twitter::RESTError => error 
            puts "Twitter exception handling #{msgType}.create request: #{error}"
          rescue StandardError => error
            puts "Exception handling #{msgType}.create request: #{error}"
          end
        end
      }
    end  
    
    #-------------------------------------------------------------------------------------------------
    def sendAutomatedReplyFromQuickBase(requestString, sendTo)
      sent = false
      @qbc.iterateRecords(@messages_dbid,[send_to_twitter],"{'#{@fieldIDs[keyword]}'.EX.'#{requestString}'}AND{'#{@fieldIDs[send_to_twitter]}'.XEX.''}"){|quickbase_record|
        begin
          response = "#{requestString}: #{quickbase_record[send_to_twitter].dup}" 
          Twitter::Message.create(:text => response,:recipient => sendTo,:client => @tc)
          puts "Automated Direct Message sent to #{sendTo}: #{response}"
          sent = true
        rescue Twitter::RESTError => error 
          puts "Twitter exception handling Twitter::Message.create request: #{error}"
        rescue StandardError => error
          puts "Exception handling Twitter::Message.create request: #{error}"
        end
      }
      sent
    end 
    
    #----------------------------------------------------------------
    def processRESTRequest(requestString, sendTo)
      sent = false
      reply = @qbc.processRESTRequest(requestString)
      response = "#{requestString}: #{reply}"
      begin
        Twitter::Message.create(:text => response,:recipient => sendTo,:client => @tc)
        puts "Automated Direct Message sent to #{sendTo}: #{response}"
        sent = true
      rescue Twitter::RESTError => error 
        puts "Twitter exception handling Twitter::Message.create request: #{error}"
      rescue StandardError => error
        puts "Exception handling Twitter::Message.create request: #{error}"
      end
      sent
    end  

    #----------------------------------------------------------------
    def quickbase_username()  "Quickbase username" end  
    def quickbase_password()  "Quickbase password" end  
    def twitter_username() "Twitter username" end  
    def twitter_password()  "Twitter password" end  
    def connection_type() "Connection type" end  
    def message_type() "Message type" end
    def keyword() "Keyword" end
    def received_from_twitter() "Received from Twitter" end
    def send_to_twitter() "Send to Twitter" end
    def sent_to_twitter() "Sent?" end
    def record_ID() "Record ID#" end
    def date_created() "Date Created" end
    
  end

end

def testQuickBaseTwitterConnector()
  QuickBase::TwitterConnector.new
end

#testQuickBaseTwitterConnector


