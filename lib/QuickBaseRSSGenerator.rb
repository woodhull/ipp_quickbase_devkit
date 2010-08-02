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

# This class generates RSS data from specific fields in one or more 
# QuickBase tables.  It is intended to make standard RSS text that can
# be displayed by RSS readers or processed by other utilities.
#
# See the test() method at the bottom of this file for an example 
# of using this class. 
#
# Note that by default this class sorts the RSS items by <pubDate>  
# descending order (i.e. most recent first); this means 
# that items generated from records from different tables can be
# interspersed which each other. Some RSS readers do not appear 
# to interpret <pubDate> correctly and therefore don't sort items
# correctly by themselves. Use 'unSorted' to prevent this class
# from sorting <items>. Also note that the sort order of records
# retrieved from tables can be set separately for each table, which
# is useful if the output is not going to be processed by an RSS readser.
class RSSGenerator

       # Nested class to encapsulate RSS retrieval options for a QuickBase table.
       class Table
           
         attr_reader :dbid, :tableName, :fields, :clist, :slist, :query, :qid, :qname, :numRecords, :options
         attr_reader :optionalFields, :title, :link, :description
               
         # 'tableName' is the table name as it should appear in the output.
         # Gets all records by default, sorted by Date Modified ("2") in descending order.
         # Only retrieves fields in 'fields' parameter.
         # <pubDate> is set to Date Modified ("2") by default
         # <link> is set to Record ID# ("3") by default
         # any additional quickbase field can be included in 'fields'
         #-----------------------------------------------------------------------------
         def initialize( dbid, tableName, fields, query = nil, qid = nil, qname = nil, numRecords = 0, slist = "2", options = "sortorder-D" )
            
            raise "fields parameter must be a Hash" if !fields.is_a?( Hash )
            
            @dbid, @tableName, @fields = dbid, tableName, fields
            @query, @qid, @qname, @numRecords, @slist, @options = query, qid, qname, numRecords, slist, options

            @fields["pubDate"] = "2" if @fields["pubDate"].nil?
            @fields["link"] = "3" if @fields["link"].nil?
            
            @optionalFields = Hash.new

            @clist = ""
            if @fields["description"] and @fields["title"]
               @fields.each{ |k,v| 
                  @clist << "#{v}." 
                  if k != "pubDate" and k != "link" and k != "description" and k != "title"
                     @optionalFields[v] = k 
                  end     
               }
               @clist[-1] = ""
            else
               raise "fields parameter must include a 'description' and 'title'" 
            end

            @title = "Default RSS Item Title"
            @link = "http://www.quickbase.com/db/main"
            @description = "Default RSS item description"
          
            @options << ".num-#{numRecords}" if numRecords > 0
         end
         
       end # class Table
       
       
      def initialize( qbc )
          raise "Bad qbc parameter. qbc must be an instance of QuickBase::Client." if !qbc.is_a?( Client )
          @qbc = qbc
          raise "Please sign into QuickBase before using the RSSGenerator class" if @qbc.ticket.nil?
          @items = Hash.new
          @sortableItems = Hash.new
          @sorted = true
          @tables = Array.new
          @timeNow = @namespace = ""
      end
   
   # Generates RSS <item>s from a filtered list of records and fields from a table.
   def generateRSSItems( table )
   
      @qbc.doQuery( table.dbid, table.query, table.qid, table.qname, table.clist, table.slist, "structured", table.options )
   
      @qbc.eachRecord { |r|

         pubDate = ""
         title = ""
         description = ""
         link = ""
         otherFieldValues = ""
         itemText = ""
         sortValue = 0
      
         @qbc.eachField(r){ |f|
                case f.attributes[ "id" ]
                    when table.fields[ "title" ] 
                        title = f.text if f.has_text?
                        next
                    when table.fields[ "description" ] 
                        description = f.text if f.has_text?
                        next
                    when table.fields[ "pubDate" ] 
                        pubDate = f.text if f.has_text?
                        next
                    when table.fields[ "link" ] 
                        link = f.text if f.has_text?
                        next
                    when table.slist 
                        sortValue = f.text if f.has_text? and @sorted
                        next
                end
                table.optionalFields.each{ |fid,fieldName|
                   if f.attributes["id"] == fid and f.has_text?
                         field, value = onSetItemField( "#{@namespace}#{fieldName}", f.text )
                         otherFieldValues << "     <#{field}>#{@qbc.encodeXML(value)}</#{field}>\n"
                   end   
                }
          }
          
          titleHash = "#{table.tableName}(#{link}): #{description[0..20]}..."
          link = "https://www.quickbase.com/db/#{table.dbid}?a=dr&rid=#{link}"

          itemText << "    <item>\n"
          
          title << " (#{table.tableName})"
          field, value = onSetItemField( "#{@namespace}title", title )
          itemText << "     <#{field}>#{@qbc.encodeXML(value)}</#{field}>\n"
          
          field, value = onSetItemField( "#{@namespace}pubDate", @qbc.formatDate(pubDate, "%a, %d %b %Y %H:%M PST" ) )
          itemText << "     <#{field}>#{value}</#{field}>\n"

          guid = link.dup
          field, value = onSetItemField( "#{@namespace}link", link )
          itemText << "     <#{field}>#{@qbc.encodeXML(value)}</#{field}>\n"
          
          field, value = onSetItemField( "#{@namespace}guid", guid )
          itemText << "     <#{field}>#{@qbc.encodeXML(value)}</#{field}>\n"
          
          field, value = onSetItemField( "#{@namespace}description", description )
          itemText << "     <#{field}>#{@qbc.encodeXML(value)}</#{field}>\n"
          
          itemText << otherFieldValues
          itemText << "    </item>\n"
          
          @items[titleHash] = itemText
          @sortableItems[titleHash] = sortValue
      
      }
      
   end
   
   # To modify item field names or values before they are inserted into the RSS output,
   # derive from this class, override this method, and modify the return values. 
   def onSetItemField( field, value )
      return field, value
   end

   # Prepend 'quickbase:' namespace to all data from QuickBase.
   # intended for use by RSS processors other than RSS Readers.
   def useNamespace
      @namespace = "quickbase:"
   end
   
   # Items are sorted by <pubDate> unless this method is called.
   def unSorted
      @sorted = false
   end
   
   # Set the title for the RSS feed generated by this class.
   def setTitle( title )
      @title = "   <#{@namespace}title>#{@qbc.encodeXML(title)}</#{@namespace}title>\n"
   end
   
   # Set the link for the RSS feed generated by this class.
   # Set isDBID = false if this is not a QuickBase dbid.   
   def setLink( link, isDBID = true )
      if isDBID
         @link = "   <#{@namespace}link>https://www.quickbase.com/db/#{link}</#{@namespace}link>\n"
      else
         @link = "   <#{@namespace}link>#{@qbc.encodeXML(link)}</#{@namespace}link>\n"
      end      
   end
   
   # Insert the current time at the end of the descripton for the RSS 
   # feed generated by this class.    
   def appendTimeToDescription
      @timeNow = " (#{Time.now})"
   end
   
   # Set the description for the RSS feed generated by this class.
   def setDescription( description, appendTime = true )
      appendTimeToDescription if appendTime
      @description = "   <#{@namespace}description>#{@qbc.encodeXML(description)}#{@timeNow}</#{@namespace}description>\n"
   end
   
   def header 
      text =  "<?xml version=\"1.0\" ?>\n"
      text << " <rss version=\"2.0\">\n"
      text << "  <channel>\n"
   end
   
   def footer
      text =   "  </channel>\n"
      text << " </rss>\n"
   end
   
   # Add a QuickBase table to the list of tables from which to generate RSS
   #
   # * dbid = QuickBase table dbid
   # * tableName = the name of the QuickBase table as it should appear in the generated RSS
   # * fields = Hash of RSS fields and the IDs of QuickBase fields , e.g. { "description" => "10", "myRSSfield" => "13" } 
   # * query, qid, qname = query parameters passed directly to QuickBase::Client,doQuery()
   # * numItems = the number of records to retrieve from QuickBase
   def addTable( dbid, tableName, fields, query = nil, qid = nil, qname = nil, numRecords = 0 )
      t = Table.new( dbid, tableName, fields, query, qid, qname, numRecords )
      @tables << t
   end
   
   # Generate all the RSS text for all the tables.
   def generateRSStext
      rssText = ""
      if @tables.length > 0
         rssText = header
         rssText << @title if @title
         rssText << @link if @link
         rssText << @description if @description
         @tables.each{ |table| generateRSSItems( table ) }
         if @sorted
            sortedItems = @sortableItems.sort{|a,b| b[1]<=>a[1] if a[1] and b[1] }
            sortedItems.each{ |item| rssText << @items[item[0]] }
         else   
            @items.each{ |item| rssText << @items[item[0]] }
         end
         rssText << footer
      else
         raise "Call addTable() one or more times before calling generateRSS"
      end
      rssText
   end
   
end # class RSSGenerator

end #module QuickBase

# The following test code generates RSS text from recently modified 
# records in the QuickBase Community Forum and KnowledgeBase.
def test( username, password )
   
   qbc = QuickBase::Client.new( username, password )
   qbRSSgen  = QuickBase::RSSGenerator.new( qbc )
   
   qbRSSgen.unSorted
   
   qbRSSgen.setTitle( "QuickBase Forum/KnowledgeBase RSS" )
   qbRSSgen.setLink( "main" )
   qbRSSgen.setDescription( "RSS view of QuickBase Community Forum and KnowledgeBase" )
   
   qbRSSgen.addTable("8emtadvk", "Community Forum", { "title" => "6", "description" => "10" }, nil, nil, nil, 75 )
   qbRSSgen.addTable( "6mztyxu8", "KnowledgeBase", { "title" => "5", "description" => "6" }, nil, nil, nil, 50 )
   
   rssText = qbRSSgen.generateRSStext
   
   File.open( "QuickBaseInfoRSS.xml", "w" ) { |file| file.write( rssText ) }
   print "\nPlease view QuickBaseInfoRSS.xml in an RSS reader, a browser or an XML editor.\n"
   
end

# uncomment the following line to test this class using 'ruby QuickBaseRSSGenerator.rb username password'
#test( ARGV[0], ARGV[1] ) if ARGV[1]

