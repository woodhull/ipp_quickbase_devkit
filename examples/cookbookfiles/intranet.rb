
require 'rubygems'
require 'ramaze'
require 'QuickBaseClient'
require 'cgi'

#-----------------------------------------------------------  
class MainController < Ramaze::Controller

  map '/'
  layout :page
   
  #-----------------------------------------------------------  
  def index
      @title = "Intranet"
      html =   "<form method=\"post\" action=\"/listQuickBaseApplications\">"
      html << "<p>User name:<input type=\"text\" name=\"username\"></input></p>" 
      html << "<p>Password :<input type=\"text\" name=\"password\"></input></p>"
      html << "<input type=\"submit\" name=\"my_quickbase\" value=\"My QuickBase.\">"     
      html << "</form>"     
   end  
  
  #-----------------------------------------------------------  
  def listQuickBaseApplications
     @title = "My QuickBase"
     if request['username'] and request['password']
      @qbc = QuickBase::Client.new(request['username'], request['password']) 
      if @qbc and @qbc.requestSucceeded
         html = ""
         grantedDBname = ""
         grantedDBid = ""
         dbproc = proc { |element|
            if element.is_a?(REXML::Element)
               if element.has_text? 
                  if element.name == "dbname"
                    grantedDBname = element.text
                  elsif element.name == "dbid"
                    grantedDBid = element.text
                  end  
               end
            end
         }
         @qbc.grantedDBs("1","1","1"){|grantedDB|
             @qbc.processChildElements(grantedDB,true,dbproc)
             html << "<br>(<a href=\"/showSchema/#{CGI.escape(request['username'])}/#{CGI.escape(request['password'])}/#{grantedDBid}/#{CGI.escape(grantedDBname)}\">schema</a>) <a href=\"https://www.quickbase.com/db/#{grantedDBid}\">#{grantedDBname}</a>" 
         }         
         html
      else
       "<p><b>Oops - something went wrong while connecting to QuickBase.<br>Please check your username and password.</b></p>"
      end    
     else
       "<p><b>Oops - please specifiy your QuickBase username and password.</b></p>"
     end  
  end     

  #-----------------------------------------------------------  
  def showSchema(username,password,dbid,dbname)
     @title = "Schema for #{dbname}"
      html = "Oops - couldn't find the schema for that table."
      @qbc = QuickBase::Client.new(username,password)
      if @qbc and @qbc.requestSucceeded
         @qbc.getSchema(dbid)
         if @qbc.requestSucceeded
           schema = ""
           
           # if you get 'undefined variable transitive' from the next line
           # edit rexml\document.rb and change 'trans=false' to ''transitive=false'
           @qbc.qdbapi.write(schema, 3)
           
           schema.gsub!("<","&lt;")
           schema.gsub!(">","&gt;")
           html = "<pre>#{schema}</pre>" 
         end
       end   
      html 
    end
    
  #-----------------------------------------------------------  
  def error
      "<p><b>Sorry - that is not a valid web page on this web site.</b></p>"
  end  

  #-----------------------------------------------------------  
   def page
    %{
<html>
  <head>
    <title>#@title</title>
  </head>
  <body>
    <h2>#@title</h2><a href ="/index">Home</a> 
    <hr>
    #@content
  </body>
</html>
    }
  end
 end
 
 Ramaze.start
 