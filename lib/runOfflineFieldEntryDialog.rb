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

require 'QuickBaseTextData'
require 'tk'

# Display a dialog with one text entry field, and buttons to send the text to a 
# field in a new record in QuickBase, go to QuickBase, and to close the dialog.
# * 'dbid' must be a valid table id. 
# * 'field' must be the name or id of a text field in the 'dbid' table.
# If you can't connect to QuickBase, data will be written to a file in your
# current working directory then sent to QuickBase next time you are
# able to connect. Note that you must have connected to QuickBase at least
# once before you can enter data offline.
def runOfflineFieldEntryDialog(username,password,dbid,field)
      
   connected = false
   appendToOfflineFile = false
   
   numTextLines = 1
   tableName = ""
   fieldID = "" 
   fieldName = ""
   
   offlineDataFileName = "#{dbid}.offline.txt"
   offlineConfigFileName = "#{dbid}.offline.cfg"
      
   if FileTest.exist?(offlineConfigFileName)
      File.open(offlineConfigFileName,"r"){|f| 
         cfg = f.gets
         tableName, numTextLines, fieldID, fieldName = cfg.split(":::")
         numTextLines = numTextLines.to_i
      }
   end
      
   @qbc = QuickBase::Client.new(username,password)
   if @qbc and @qbc.requestSucceeded
      connected = true
      if FileTest.exist?(offlineDataFileName)
         QuickBase::TextData.uploadData(username,password,offlineDataFileName)
         File.delete(offlineDataFileName)
      end
   else
      appendToOfflineFile = true if FileTest.exist?(offlineDataFileName)
   end   
      
   @offlineDataFile = nil
   if connected
      @qbc.getSchema(dbid)
      if @qbc.requestSucceeded
         field = field.join(' ')
         field.strip!
         fieldID = @qbc.lookupFieldIDByName(field)
         if fieldID
            fieldName = field
         else
            fieldName = lookupFieldNameFromID(field)
            fieldID = field if fieldName
         end
         tableName = @qbc.getResponseElement( "table/name" ).text
         if fieldID and fieldName
            fieldElement = @qbc.lookupField(fieldID)
            numLinesProc = proc { |element|
               if element.is_a?(REXML::Element) and element.name == "num_lines" and element.has_text?
                  numTextLines = element.text.to_i
               end
            }
            @qbc.processChildElements(fieldElement, true, numLinesProc)
            File.open(offlineConfigFileName,"w"){|f|f.write("#{tableName}:::#{numTextLines}:::#{fieldID}:::#{fieldName}")}
         else
            Tk.messageBox({"icon"=>"error","title"=>"Oops!", "message" => "Error finding the QuickBase field '#{fieldName}' in the '#{tableName}' table."})      
         end
      else
         Tk.messageBox({"icon"=>"error","title"=>"Oops!", "message" => "Error finding the QuickBase table with the '#{dbid}' id."})      
      end
   elsif appendToOfflineFile
      @offlineDataFile = File.open(offlineDataFileName, "a")
   else   
      @offlineDataFile = File.open(offlineDataFileName, "w")
      @offlineDataFile.puts("dbid:#{dbid}")
   end
            
   root = TkRoot.new{ title tableName }
   frame = TkFrame.new(root){
       borderwidth 4 
       width 60
       pack "side" => "top"
   }
   if numTextLines == 1
      labelText = "Enter '#{fieldName}' and press Enter or click 'Send to QuickBase':"
   else
      labelText = "Enter '#{fieldName}' and click 'Send to QuickBase':"
   end
   fieldLabel = TkLabel.new(frame){
       text labelText
       font "Arial 10 bold"
       pack "side"=>"top", "expand" => true 
   }
   
   entryField = nil
   if numTextLines == 1
      entryField = TkEntry.new(frame){
          font "Arial 10 bold"
          pack "fill" => "x", "expand" => true, "side" => "top",  "padx" =>5, "pady"=>5  
      }
      entryField.bind('Key-Return') {|e|  
         value = entryField.get
         if connected
            @qbc.clearFieldValuePairList
            @qbc.addFieldValuePair(nil,fieldID,nil,value)
            @qbc.addRecord(dbid,@qbc.fvlist)
         else
            @offlineDataFile.puts("record:\n#{fieldName}:#{value}")
         end
         entryField.value = ""
      }
   elsif numTextLines > 1
      entryField = TkText.new(frame){
          height numTextLines
          width 60
          font "Arial 10 bold"
          pack "fill" => "both", "expand" => true, "side" => "top",  "padx" =>5, "pady"=>5  
          wrap "word"
      }
   end
   entryField.focus
   
   buttonFrame = TkFrame.new(frame){
       pack "side" => "bottom"
       width 50 
   }
   sendButton = TkButton.new(buttonFrame){
       text "Send To QuickBase" 
       underline 0
       font "Arial 10 bold"
       pack "side"=>"left", "padx"=>5, "pady"=>5
   }
   sendButton.command {
      if numTextLines > 1
         value = entryField.get("1.0","end")
      else
         value = entryField.get
      end
      if connected
         @qbc.clearFieldValuePairList
         @qbc.addFieldValuePair(nil,fieldID,nil,value)
         @qbc.addRecord(dbid,@qbc.fvlist)
      else
         @offlineDataFile.puts("record:\n#{fieldName}:#{value}")
      end
      entryField.value = ""
   }
    
   if connected
      launchButton = TkButton.new(buttonFrame){
          text "Go to QuickBase..." 
          underline 0
          font "Arial 10 bold"
          pack "side"=>"left","padx"=>5, "pady"=>5
      }
      launchButton.command {
         url = "http://www.quickbase.com/db/#{dbid}"
         url = "start #{url}" if RUBY_PLATFORM.split("-")[1].include?("mswin")  
         system(url)
      }
   end
   closeButton = TkButton.new(buttonFrame){
       text "Close" 
       underline 0
       font "Arial 10 bold"
       pack "side"=>"right","padx"=>5, "pady"=>5
   }
   closeButton.command { Tk.exit }
   
   root.bind('Alt-KeyRelease-s') {|e| sendButton.invoke }
   root.bind('Alt-KeyRelease-l') {|e| launchButton.invoke }
   root.bind('Alt-KeyRelease-c') {|e| closeButton.invoke }

   Tk.mainloop
end

if ARGV[3]
   runOfflineFieldEntryDialog(ARGV[0],ARGV[1],ARGV[2],ARGV[3..-1])
else
   puts "\nusage: ruby runOfflineFieldEntryDialog.rb username password dbid field"
   puts "\n'dbid' must be a valid table id." 
   puts "'field' must be the name or id of a text field in the 'dbid' table."
   puts "'field' can be more than one word, e.g. 'To-Do Item'."
   puts "If you can't connect to QuickBase, data will be written to a file in"
   puts "your current working directory then sent to QuickBase next time you"
   puts "are able to connect. Note that you must have connected to QuickBase"
   puts "at least once before you can enter data offline.\n"
end
