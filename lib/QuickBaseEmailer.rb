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

require "QuickBaseClient"
require "net/smtp"

#require 'tls_smtp'

module QuickBase

   # Simple class to read data from QuickBase and email it using the SMTP client that
   # comes with Ruby.  This class should handle sending emails to people in the same domain
   # as you, e.g. when your 'from' and 'to' email addresses all end in '@ourcompany.com'.
   # To send emails outside your domain, it's likely that you will have to override
   # the sendUnauthenticatedEmail() method or the sendAuthenticatedEmail() method
   # and add authentication acceptable to your email server.
   #
   # To send  email via GMail's server: 
   #
   # * download http://s3.amazonaws.com/drawohara.com.ruby/tls_smtp.rb
   # * comment out the 'require "net/smtp"' line above
   # * uncomment the #require 'tls_smtp' line
   # * use smtp.gmail.com as the mail server
   #
   class Emailer
   
      attr_writer :from, :to, :subject, :message 
      attr_writer :mailServer, :mailPort, :fromDomain, :authenticationType
      attr_writer :emailUsername, :emailPassword
      
      def initialize(username,password, emailUsername=nil, emailPassword=nil)
         @username,@password = username,password
         @emailUsername, @emailPassword=emailUsername, emailPassword
         @emailUsername = @username if @emailUsername.nil?
         @emailPassword = @password if @emailPassword.nil?
         @mailPort = 25
      end
       
      def sendBccEmail(from, to, bcc, subject, message, mailServer, mailPort, fromDomain)
        @bcc = bcc.dup
        sendEmail(from, to, subject, message, mailServer, mailPort, fromDomain)
        @bcc = nil
      end
      
      def sendEmail(from, to, subject, message, mailServer, mailPort, fromDomain)
      
         @from = from if from
         @to = to if to
         @subject = subject if subject
         @message = message if message 
         @mailServer = mailServer if mailServer
         @mailPort = mailPort if mailPort
         @fromDomain = fromDomain if fromDomain
         
         if validateEmailData
            email = buildEmail(@from,@to,@subject,@message)
            @to = @to + @bcc if @bcc
            if @authenticationType.nil? or @authenticationType == ""
               sendUnauthenticatedEmail(email,@from,@to,@mailServer, @mailPort, @fromDomain)
            else   
               sendAuthenticatedEmail(email,
                                                @from,
                                                @to,
                                                @mailServer, 
                                                @mailPort, 
                                                @fromDomain,
                                                @emailUsername, 
                                                @emailPassword,
                                                @authenticationType )
            end
         end
         
      end
      
      def sendUnauthenticatedEmail(email,from,to,mailServer, mailPort, fromDomain)
         begin
            Net::SMTP::start(mailServer,mailPort,fromDomain) { |smtp|
               smtp.send_message(email,from,to)
            }
         rescue StandardError => error
            raise "Error sending email: #{error}"
         end
      end
      
      def sendAuthenticatedEmail(email,from,to,mailServer, mailPort, fromDomain, 
                                                emailUsername,emailPassword,authenticationType)
           begin
            Net::SMTP::start(mailServer,mailPort,fromDomain,emailUsername,emailPassword,authenticationType) { |smtp|
               smtp.send_message(email,from,to)
            }
         rescue StandardError => error
            raise "Error sending email: #{error}"
         end
      end
      
      def validateEmailData
         
         raise "'@from' email address is missing" if @from.nil?
         raise "'@to' email address is missing" if @to.nil?
         @subject = "" if @subject.nil?
         @message = "" if @message.nil?
         raise "'@mailServer' is missing" if @mailServer.nil?
         raise "'@mailPort' is missing" if @mailPort.nil?

         raise "'@mailServer' must be a String" if not @mailServer.is_a?(String)
         
         if @mailServer and @fromDomain.nil?
            @fromDomain = @mailServer
         end
         
         raise "'@fromDomain' must be a String" if not @fromDomain.is_a?(String)
         
         if not @to.is_a?(Array)
            raise "'@to' must be an Array"
         end
         
         @to.each { |toAddress|
            if not toAddress.index('@')
               raise "'#{toAddress}' is not a valid email address"
            end
         }
         
         if @bcc
            if not @bcc.is_a?(Array)
               raise "'@bcc' must be an Array"
            end
         
            @bcc.each { |toAddress|
               if not toAddress.index('@')
                  raise "'#{toAddress}' is not a valid email address"
               end
            }
         end
         
         if not @from.is_a?(String)
            raise "'@from' must be an String"
         end
         
         if not @from.index('@')
            raise "'@from' is not a valid email address"
         end
         
         if not @mailPort.is_a?(Numeric)
            raise "'@mailPort' must be a positive number"
         end
         
         raise "'@subject' must be a String" if not @subject.is_a?(String)
         raise "'@message' must be a String" if not @message.is_a?(String)
         
         if @authenticationType and @authenticationType != ""
            if not ["login","cram-md5","plain"].include?(@authenticationType)
               raise "'@authenticationType' #{@authenticationType} is invalid."
            end
         end
         
         true
      end
      
      def buildEmail(from,to,subject,message)
         from.strip!
         email = "From:#{from}\n"
         email << "Date:#{Time.now}\n"
         to.each{|toAddress|
            toAddress.strip!
            email << "To:#{toAddress}\n" 
         }
         email << "Subject:#{subject}\n"
         email << "#{message}\n"
         email
      end

      def readEmailServerConfigFromQuickBase(dbid,fieldNames,fids,query=nil,qname=nil,qid=nil)
         emailConfiguration = nil
         if not fids.is_a?(Hash)
            raise "'fids' must be a Hash of email server configuration field names and their QuickBase field id's"
         end
         if not fieldNames.is_a?(Hash)
            raise "'fieldNames' must be a Hash of email configuration fields and their field names in QuickBase"
         end
         clist = ""
         ["mailServer","mailPort","fromDomain","authenticationType"].each{|fieldName|
            if fids[fieldName]
               clist << fids[fieldName]
               clist << "." unless fieldName == "authenticationType"
            else
               raise "'#{fieldName}' fid entry is missing from the 'fids' Hash"
            end
            if not fieldNames[fieldName]
               raise "'#{fieldName}' QuickBase field name entry is missing from the 'fieldNames' Hash"
            end
         }
         qbc = QuickBase::Client.new(@username,@password)
         if qbc and qbc.requestSucceeded
            qbc.getSchema(dbid)
            if qbc.requestSucceeded
               emailConfiguration = qbc.getAllValuesForFields(dbid,fieldNames.values,query,qname,qid,clist,nil,"structured","num-1")
               emailConfiguration = nil if emailConfiguration.length == 0
            else
               raise "Error accessing QuickBase table '#{dbid}'."
            end
         else
            raise "Error accessing QuickBase. Please check your internet connection, username (#{@username}) and password (#{@password})"
         end
         qbc.signOut if qbc
         emailConfiguration
      end
      
      def readEmailsToSendFromQuickBase(dbid,fieldNames,fids,query=nil,qname=nil,qid=nil)
         emailMessages = nil
         if not fids.is_a?(Hash)
            raise "'fids' must be a Hash of email field names and their QuickBase field id's"
         end
         if not fieldNames.is_a?(Hash)
            raise "'fieldNames' must be a Hash of email fields and their field names in QuickBase"
         end
         clist = ""
         ["from","to","subject","message"].each{|fieldName|
            if fids[fieldName]
               clist << fids[fieldName]
               clist << "." unless fieldName == "message"
            else
               raise "'#{fieldName}' fid entry is missing from the 'fids' Hash"
            end
            if not fieldNames[fieldName]
               raise "'#{fieldName}' QuickBase field name entry is missing from the 'fieldNames' Hash"
            end
         }
         qbc = QuickBase::Client.new(@username,@password)
         if qbc and qbc.requestSucceeded
            qbc.getSchema(dbid)
            if qbc.requestSucceeded
               emailMessages = qbc.getAllValuesForFields(dbid,fieldNames.values,query,qname,qid,clist)
               emailMessages = nil if emailMessages.length == 0
            else
               raise "Error accessing QuickBase table '#{dbid}'."
            end
         else
            raise "Error accessing QuickBase. Please check your internet connection, username and password"
         end
         qbc.signOut if qbc
         emailMessages
      end
      
      def sendEmailMessages(emailMessages, emailConfiguration)
         if emailMessages and emailConfiguration
            raise "'emailMessages' must be a Hash" if not emailMessages.is_a?(Hash)
            raise "'emailConfiguration' must be a Hash" if not emailConfiguration.is_a?(Hash)
            (0..(emailMessages["from"].length-1)).each{|i|
               begin
            
                  from = emailMessages["from"][i]
                  toAddresses = emailMessages["to"][i].split(/\<BR\/\>/)
                  subject = emailMessages["subject"][i]
                  subject.gsub!("<BR/>","")
                  message = emailMessages["message"][i]
                  message.gsub!("<BR/>","")        
                  
                  sendEmail(from,
                                toAddresses,
                                subject,
                                message,
                                emailConfiguration["mailServer"][0],
                                emailConfiguration["mailPort"][0].to_i, 
                                emailConfiguration["fromDomain"][0])
                                
                  puts "Sent '#{subject}' email."             
                                
               rescue StandardError => error
                  puts error
               end
            }
         end
      end
      
      def Emailer.sendEmailsFromQuickBase(username,password,configDBID,emailsDBID)
         emailer = Emailer.new(username,password)
         
         configFieldNames = Hash.new
         configFieldNames["mailServer"]="mailServer"
         configFieldNames["mailPort"]="mailPort"
         configFieldNames["fromDomain"]="fromDomain"
         configFieldNames["authenticationType"]="authenticationType"
         
         configFieldIDs = Hash.new
         configFieldIDs["mailServer"]="6"
         configFieldIDs["mailPort"]="7"
         configFieldIDs["fromDomain"]="8"
         configFieldIDs["authenticationType"]="9"
         
         emailConfiguration = emailer.readEmailServerConfigFromQuickBase(configDBID,configFieldNames,configFieldIDs)
         if emailConfiguration
            puts "Read an email configuration from '#{configDBID}'."         

            emailFieldNames = Hash.new
            emailFieldNames["from"]="from"
            emailFieldNames["to"]="to"
            emailFieldNames["subject"]="subject"
            emailFieldNames["message"]="message"
            
            emailFieldIDs = Hash.new
            emailFieldIDs["from"]="6"
            emailFieldIDs["to"]="7"
            emailFieldIDs["subject"]="8"
            emailFieldIDs["message"]="9"
            
            emailMessages = emailer.readEmailsToSendFromQuickBase(emailsDBID,emailFieldNames,emailFieldIDs)
            if emailMessages and emailMessages["from"].length > 0
               numMessages = emailMessages["from"].length
               puts "Read #{numMessages} email messages from '#{emailsDBID}'."         
               emailer.sendEmailMessages(emailMessages, emailConfiguration)
            else   
               puts "Did not read email messages from '#{emailsDBID}'."         
            end
         else
            puts "Did not read an email configuration from '#{configDBID}'."         
         end
      end
      
   end #class Emailer
   
end #module QuickBase

#QuickBase::Emailer.sendEmailsFromQuickBase(ARGV[0],ARGV[1],ARGV[2],ARGV[3]) if ARGV[3]

