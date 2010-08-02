require 'QuickBaseClient'
require 'cgi'

if ARGV.length < 2
   puts "\n Usage: ruby downloadCookbook.rb <username> <password>\n"
   puts "\n This script copies the recipes from the QuickBase API Cookbook to your local drive.\n"
   exit
end

qbc = QuickBase::Client.new( ARGV[0], ARGV[1] )

fieldsToDownload = [ "Record ID#", "Title", "Keywords", "Problem", "Solution", "Discussion", "See Also", "File Attachment", "Ingredient 1",  "Ingredient 2", "Ingredient 3", "Chef" ]

# this is the original QuickBase API Cookbook v3 recipes table
fieldValues = qbc.getAllValuesForFields( "bcdcajmrg", fieldsToDownload, nil, nil, "List All" )

numRecs = fieldValues[ "Record ID#" ].length

cwd=Dir.getwd 
fileprefix = "#{cwd}/cookbookfiles/"
Dir.mkdir( fileprefix ) if !File.exists?( fileprefix )
Dir.chdir( fileprefix ) 

File.open( "QuickBaseAPICookbook.html", "w" ) { |outputFile |

outputFile.write( "<HTML><HEAD><TITLE>QuickBase API Cookbook v3</TITLE></HEAD><BODY><H1><a href=\"https://www.quickbase.com/db/bcdcajmrg\">QuickBase API Cookbook v3</a></H1>" )

(0..numRecs.to_i-1).each{ |i|

   link = ""
   title = ""
   keywords = ""
   problem = ""
   solution = ""
   discussion =""
   seeAlso = ""
   file = ""
   ingredient1 = ""
   ingredient2 = ""
   ingredient3 = ""
   chef = ""
   recordID = ""
   
   fieldValues.each { |fieldName,valueArray|
   
       # get the value of fieldName in record i
       value = valueArray[i]
       
       value.gsub!("<BR/>","\n")
       
       case fieldName
          when "Record ID#" 
	     link = "https://www.quickbase.com/db/bcdcajmrg?a=dr&rid=#{value}"
	     recordID = value.dup
	  when "Title" then title = "#{CGI.escapeHTML(value)}"
	  when "Keywords" then keywords = "<h3>Keywords</h3>#{CGI.escapeHTML(value)}<br>"
	  when "Problem" then problem = "<h3>Problem:</h3>#{CGI.escapeHTML(value)}<br>"
	  when "Solution" then solution = "<h3>Solution:</h3><pre>#{CGI.escapeHTML(value)}</pre><br>"
	  when "Discussion" then discussion = "<h3>Discussion:</h3>#{CGI.escapeHTML(value)}<br>"
	  when "See Also" then seeAlso = "<h3>See Also:</h3>#{CGI.escapeHTML(value)}<br>"
	  when "File Attachment" 
	     if value.length > 0
	        fileToWrite = "#{fileprefix}#{value}"
	        #file = "<h3>File Attachment:</h3><a href=\"file:///#{fileprefix}#{value}\">#{fileprefix}#{value}</a><br>" 
	        file = "<h3>File Attachment:</h3><a href=\"#{value}\">#{value}</a><br>" 
	        qbc.downLoadFile(qbc.dbid, recordID, "12" )
           fileContents = qbc.fileContents.dup
            if fileContents.length > 0
               fileContents.gsub!( "\r\n", "\n" )
               File.open( fileToWrite, "w" ){|f|f.write(fileContents) }
            end
	     end 
	  when "Ingredient 1" then ingredient1 = "<h3>Ingredients:</h3>#{CGI.escapeHTML(value)}, "
	  when "Ingredient 2" then ingredient2 = "#{CGI.escapeHTML(value)}, "
	  when "Ingredient 3" then ingredient3 = "#{CGI.escapeHTML(value)}<br>"
	  when "Chef" then chef = "<h3>Chef:</h3>#{CGI.escapeHTML(value)}<br>"
       end
   }
   
   title = "<h2><a href=\"#{link}\">#{title}</a>"
   
   outputFile.write( title )
   outputFile.write( keywords )
   outputFile.write( problem )
   outputFile.write( solution )
   outputFile.write( discussion )
   outputFile.write( seeAlso )
   outputFile.write( file )
   outputFile.write( ingredient1)
   outputFile.write( ingredient2 )
   outputFile.write( ingredient3 )
   outputFile.write( chef )
   outputFile.write( "<HR>" )
}
outputFile.write( "</BODY>" )

}
