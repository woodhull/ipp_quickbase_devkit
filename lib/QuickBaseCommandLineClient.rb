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

#   This implements an extensible command line interface to QuickBase.
#   Use setCommand() and setCommandAlias() to extend or modify the interface.
#
#   Call run() to use the command line interactively.
#
#   Call run( filename ) to run the commands in a file.
#
#   Commands entered during an interactive session can be recorded to a file.
#
#   In addition to the @commands loaded in initialize(), any public method
#   from class Client can be used as a command, and any line of Ruby code
#   can be executed.
#  
#   Run a command line client session interactively, or using the commands in a file. e.g.:
#   * ruby QuickBaseCommandLineClient.rb run
#   * ruby QuickBaseCommandLineClient.rb run dailyTasks.qbc
#   * ruby -e "require 'quickbasecommandlineclient';QuickBase::CommandLineClient.new.run"
#  
class CommandLineClient < Client

  attr_reader :usage, :commands, :aliases, :availableCommands

  # Information needed to display and run a command
  class Command
     attr_reader :name, :desc, :prerequisite, :args, :code, :prompt
     def initialize( name, desc, prerequisite, args, code, prompt = nil )
        @name, @desc, @prerequisite, @args, @code, @prompt = name, desc, prerequisite, args, code, prompt
     end
  end

  # Display a message telling the user what to do.
  def showUsage
     if @usage.nil?
        @usage = <<USAGE

 Enter a command from the list of available commands.
 The list of commands may change after each command.
 Type TABs, commas, or spaces between parts of a command.
 Use double-quotes if your commands contain TABs, commas or spaces.

 e.g. addfield "my text field" text

USAGE
     end

     puts @usage
  end

  # Set up some basic commands and their abbreviations
  def initialize
     super

     # the main purpose of commands and aliases loaded here is reduce the
     # steps, typing and clicking needed to get simple things done in QuickBase

     setCommand( "signin",   "Sign into QuickBase",                     "@ticket.nil?", [ "username", "password" ], [ :authenticate ] )

     setCommand( "create",   "Create an application",                   "@ticket", [ "application name", "description" ], [ :createDatabase, :onChangedDbid ] )
     setCommand( "copy",     "Copy an application, with/out data",      "@ticket and @dbid", [ "name", "desc", "keep data?" ], [ :_cloneDatabase, :onChangedDbid ] )
     setCommand( "open",     "Open an application",                     "@ticket", [ "application name" ], [ :findDBByname, :onChangedDbid ] )
     setCommand( "use",      "Use a table from the current application","@ticket and @dbid and @chdbids", [ "table name" ], [ :lookupChdbid, :onChangedDbid ] )

     setCommand( "select",   "Select records using a query name",       "@ticket and @dbid", [ "query name" ], [ :_doQueryName, :resetrid ] )
     setCommand( "setrecord",   "Set the active record",                "@ticket and @dbid", [ "record number" ], [ :_setActiveRecord ] )

     setCommand( "changerecords", "Conditionally set field value",      "@ticket and @dbid and @fields", [ "field", "value", "testfld", "test", "testval" ], [ :changeRecords ], "Are you sure?" )
     setCommand( "deleterecords", "Conditionally delete records",       "@ticket and @dbid and @fields", [ "test field", "test", "test value" ], [ :deleteRecords ], "Are you sure?" )
     setCommand( "deleteallrecords", "Delete all records",              "@ticket and @dbid", nil, [ :deleteRecords, :resetrid ], "Are you sure?" )

     setCommand( "addrecord","Add a record to the active table",        "@ticket and @dbid", nil, [ :_addRecord, :_getRecordInfo ] )
     setCommand( "setfield", "Set a field value in the active record",  "@ticket and @dbid and @rid", [ "field name", "value"], [ :setFieldValue ] )

     setCommand( "addfield", "Add a field to the active table",         "@ticket and @dbid", [ "field name" , "field type" ], [ :_addField ] )
     setCommand( "addfieldchoices", "Add value choices for a field",    "@ticket and @dbid", [ "field name" , "[choice1,choice2]" ], [ :_fieldNameAddChoices ] )

     setCommand( "importfile","Import records from a CSV file",         "@ticket and @dbid", [ "file name" ], [ :importCSVFile, :resetrid ] )
     setCommand( "importexcelfile","Import records from Excel",         "@ticket and @dbid", [ "Excel(.xls) file name", "last import column" ], [ :_importFromExcel, :resetrid ] )
     setCommand( "exportfile","Export records to a CSV file",           "@ticket and @dbid", [ "file name" ], [ :makeSVFile ] )

     setCommand( "uploadfile", "Upload a file into a new record",       "@ticket and @dbid", [ "file name", "file attachment field name" ], [:_uploadFile]  )
     setCommand( "updatefile", "Update the file attachment in a record","@ticket and @dbid and @rid", [ "file name", "file attachment field name" ], [:_updateFile]  )

     setCommand( "deletefield", "Delete a field from the active table", "@ticket and @dbid", [ "field name" ], [:_deleteFieldName], "Are you sure?" )
     setCommand( "deletetable", "Delete the active table",              "@ticket and @dbid", nil, [ :_deleteDatabase, :resetrid ], "Are you sure?" )

     setCommand( "print",    "Prints the results of the last command",  "@ticket", nil, [ :_printChildElements ] )
     setCommand( "listapps", "Lists the applications you can access",   "@ticket", nil, [ :grantedDBs, :_printChildElements ] )

     setCommand( "uselog", "Logs requests and responses to a file",     "true",  [ "log file" ], [ :logToFile ] )

     setCommand( "signout",  "Sign out of QuickBase",                   "@ticket", nil, [ :signOut ] )

     @aliases = { "si" => "signin", "la" => "listapps", "o" => "open",
                  "p" => "print", "so" => "signout", "af" => "addfield",
                  "sel" => "select", "ar" => "addrecord", "sf" => "setfield",
                  "sr" => "setrecord", "q" => "quit", "if" => "importfile",
                  "ef" => "exportfile", "ulf" => "uploadfile", "udf" => "updatefile",
                  "r" => "run", "ul" => "uselog"  }

  end

  # Add a command to the list of available commands
  def setCommand( name, desc, prerequisite, args, code, prompt = nil )
     @commands = Hash.new if @commands.nil?
     cmd = Command.new( name, desc, prerequisite, args, code, prompt )
     @commands[ name ] = cmd
  end

  # Set the alias, or abbreviation, for a command
  def setCommandAlias( anAlias, cmd )
     @aliases = Hash.new if @aliases.nil?
     @aliases[ anAlias ] = cmd
  end

  # Get a list of commands that are valid now
  def evalAvailableCommands
     @availableCommands = Array.new
     @commands.each{ |name,cmd|
         @availableCommands << name if eval( cmd.prerequisite )
       }
  end

  # Make a string to display a command to the user
  def cmdString( command, include_desc = true )

     ret = ""

     cmd = @commands[command]
     if cmd

        cmdalias = ""
        if @aliases and @aliases.has_value?( cmd.name )
           @aliases.each{ |k,v| cmdalias << "#{k}," if v == cmd.name }
           cmdalias[-1] = ""
           cmdalias = "(#{cmdalias})"
        end

        if cmd.args
           if include_desc
              ret = "#{cmd.name}#{cmdalias} '#{cmd.args.join( ',' )}': #{cmd.desc}"
           else
              ret = "#{cmd.name}#{cmdalias} '#{cmd.args.join( ',' )}'"
           end
        else
           if include_desc
              ret = "#{cmd.name}#{cmdalias} : #{cmd.desc}"
           else
              ret = "#{cmd.name}#{cmdalias}"
           end
        end
     end
     ret
  end

  # Display the commands currently available
  def showAvailableCommands
     evalAvailableCommands
     puts "\nCommands available:"
     puts
     puts " quit(q): End this command session"
     puts " usage: Show how to use this program"
     puts " ruby 'rubycode': run a line of ruby language code"
     puts " run(r) 'filename': run the commands in a file"
     puts " record 'filename': records your commands in a file"
     @availableCommands.sort().each { |cmd| puts " #{cmdString( cmd )}" }
     puts "\n"
  end

  # Prompt the user if a command requires an 'Are you sure?' type of response
  def prompt( promptString )
     if promptString
        print "#{promptString} (Press 'y' if Yes): "
        yn = gets
        yn.chop!
        return false if yn != "y"
     end
     true
  end

  # The main command entry and processing loop
  def run( filename = nil )

     begin

        if filename
           file = File.new( filename )
        else
           showUsage
        end

        recordedCommandsFile = nil

        loop {

           resetErrorInfo

           if filename.nil?
              showAvailableCommands

              print "Enter a command: "
              inputLine = gets

           else
              evalAvailableCommands
              inputLine = file.gets
              break if inputLine.nil?
           end

           if inputLine.index( '\t' )
              separator = "\t"
           elsif inputLine.index( "," )
              separator = ","
           else
              separator = " "
           end

           args = inputLine.split
           inputcommand = args[0]

           if filename.nil? and recordedCommandsFile and inputcommand != "record"
              recordedCommandsFile.write( inputLine )
           end

           input = splitString( inputLine, separator )

           if input and input.length > 0

              (0..input.length-1).each{ |i| input[i].strip!;input[i].gsub!( "\"", "") }

              if @aliases and @aliases.include?( inputcommand )
                 command = @aliases[ inputcommand ]
              else
                 command = inputcommand
              end

              break if command == "quit"

              if command == "usage"
                 showUsage
              elsif command == "record"
                 if input.length == 2
                    recordedCommandsFile.close if recordedCommandsFile
                    recordedCommandsFile = File.open( input[ 1 ], "w" )
                    puts "Unable to open file '#{input[ 1 ]}' for writing." if recordedCommandsFile.nil?
                 elsif input.length < 2
                    puts "Command file name is missing. Enter 'record filename'"
                 end
              elsif command == "run"
                 if input.length == 2 and FileTest.readable?( input[ 1 ] )
                    run( input[ 1 ] )
                 elsif input.length < 2
                    puts "Command file name is missing. Enter 'run filename'"
                 else
                    puts "'#{input[1]}' is not a readable file"
                 end
              elsif command == "ruby"
                 begin
                    inputLine.sub!( "ruby", "" )
                    puts inputLine
                    eval( inputLine )
                 rescue StandardError => e
                    puts "Error: #{e}"
                 end
              elsif command == "?"
                 showAvailableCommands
                 puts "API commands:\n#{clientMethods().sort().join(', ')}\n"
              elsif @commands and @commands.include?( command ) and @availableCommands.include?( command )

                 cmd = @commands[ command ]
                 input.shift

                 if cmd.args and cmd.args.length == 1
                    inputLine.sub!( inputcommand, "" )
                    inputLine.strip!
                    input = [ inputLine ]
                 end

                 if prompt( cmd.prompt )
                    begin
                       if cmd.args and input.length == cmd.args.length
                          case input.length
                            when 1
                              puts "#{cmd.code[0]}( #{input[0]} )"
                              send( cmd.code[0], input[0] )
                            when 2
                              puts "#{cmd.code[0]}( #{input[0]}, #{input[1]} )"
                              send( cmd.code[0], input[0], input[1] )
                            when 3
                              puts "#{cmd.code[0]}( #{input[0]}, #{input[1]}, #{input[2]} )"
                              send( cmd.code[0], input[0], input[1], input[2] )
                            when 4
                              puts "#{cmd.code[0]}( #{input[0]}, #{input[1]}, #{input[2]} , #{input[3]})"
                              send( cmd.code[0], input[0], input[1], input[2], input[3] )
                            when 5
                              puts "#{cmd.code[0]}( #{input[0]}, #{input[1]}, #{input[2]} , #{input[3]}, #{input[4]})"
                              send( cmd.code[0], input[0], input[1], input[2], input[3], input[4] )
                          end

                          (1..cmd.code.length-1).each{ |c|
                              puts "#{cmd.code[c]}"
                              send( cmd.code[c] )
                          }

                       elsif cmd.args.nil?
                          cmd.code.each{ |c|
                             puts "#{c}"
                             send( c )
                          }
                       else
                          puts "Information missing: #{cmdString( command, false )}"
                       end
                    rescue StandardError => e
                       puts "Error: #{e}"
                    end
                 end

              elsif clientMethods().include?( command )
                 puts inputLine
                 begin
                    eval( inputLine )
                 rescue StandardError => e
                    puts "Error: #{e}"
                 end
              else
                 puts "Invalid command '#{inputcommand}'"
              end

              if (!@requestSucceeded.nil?) and @requestSucceeded == false
                 puts "\n#{@lastError}"
              end

              if filename.nil?
                 print "\nPress Enter to continue..."
                 gets
              end

           end

        }

     rescue StandardError => e
        puts "Error: #{e}"
     ensure
        signOut if @ticket and filename.nil?
        recordedCommandsFile.close if recordedCommandsFile
     end
  end

end #class CommandLineClient -------------------------------------

end #module QuickBase ---------------------------------------------

def testQuickBaseCLClient( filename = nil )
  include QuickBase
  qbCLClient = CommandLineClient.new
  qbCLClient.run( filename )
end

#-----------------------------------------------------------------------------------
# To test the QuickBase::CommandLineClient, copy the #require 'QuickBaseCommandLineClient'
# and '#testQuickBaseCLClient' lines # below into testQBCLC.rb, uncomment the
# lines and run 'ruby testQBCLC.rb' .
#-----------------------------------------------------------------------------------
#require 'QuickBaseCommandLineClient'
#testQuickBaseCLClient

# Run a command line client session interactively, or using the commands in a file.
# e.g. ruby QuickBaseCommandLineClient.rb run
# e.g. ruby QuickBaseCommandLineClient.rb run dailyTasks.qbc
if __FILE__ == $0 and ARGV.length > 0
   if ARGV[0] == "run"
      qbclc = QuickBase::CommandLineClient.new
      if ARGV.length > 1
         if FileTest.readable?( ARGV[1] )
            qbclc.run( ARGV[1] )
         else
            puts "File '#{ARGV[1]}' is not a readable file."
         end
      else
         ARGV.shift
         qbclc.run()
       end
   end    
end
