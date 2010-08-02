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

require 'WorkPlaceClient'

# usage: ruby QuickBaseContactsAppBuilder.rb username password [useWorkPlace].
# Creates a very simple Contacts database in QuickBase and a Rails app for it.
class QuickBaseContactsAppBuilder 
   
   def initialize(username,password,useWorkPlace=nil)
      begin
         if useWorkPlace
           @qbc = QuickBase::WorkPlaceClient.new(username,password)
         else  
           @qbc = QuickBase::Client.new(username,password)
         end
         
         raise @qbc.errtext if ! @qbc.requestSucceeded
       
        @useWorkPlace = useWorkPlace
        @username, @password = username,password
        
        @rails_appname = @username.downcase.gsub( /\W/, "_" )
        @rails_appname << "_contacts"
        @rootClassName = ""
        @rails_appname.split(/_/).each{|s| @rootClassName << s.capitalize }
        @modelClassName = @rootClassName.dup
        @modelClassName[-1] = ""
        @modelFileName = @rails_appname.dup
        @modelFileName[-1] = ""
        @modelFileName << ".rb"
        
        buildApp
      rescue StandardError => connectionError
         puts "\n\nError connectiong to #{ useWorkPlace ? 'workplace.intuit.com' : 'www.quickbase.com'}: #{connectionError}\n\n" 
      end      
   end
   
   private
   
   def buildApp
      if runRailsCommand
        #@qbc.printRequestsAndResponses=true
        if @qbc.findDBByName(@rails_appname) or @qbc.createDatabase(@rails_appname,"This application was generated using QuickBaseContactsAppBuilder.rb.")
           begin
              @contactsTableID = @qbc.lookupChdbid(@rails_appname, @qbc.dbid)
              addFields
              addSampleData
              begin
                 generateRailsFiles
                 displayDoneMsg
              rescue StandardError => localerror
                 puts "\n\nError generating rails files: #{localerror}\n\n"
              end
           rescue StandardError => qberror
              if qberror.to_s.include?("Invalid Application Token")
                 puts "\n\nPlease go to QuickBase, open the '#{@rails_appname}' app, uncheck 'Require Application Tokens' and run this ruby script again.\n\n"
              else
                 puts "\n\nError adding fields or data to the '#{@rails_appname}' app: #{qberror}."
                 puts "Please go to QuickBase, open the '#{@rails_appname}' app, uncheck 'Require Application Tokens' and run this ruby script again.\n\n"
              end  
           end
        else
           puts "Error creating the #{@rails_appname} application.\nAre '#{@username}' and '#{@password}' correct?\n"
        end
     else
           puts "Error running 'rails #{@rails_appname}'.\n"
     end       
   end
   
   def fields
      ["name","phone","email","title","company"]
   end
  
   def addFields
      @clist = ""
      fields.each{|field| 
         id,label = @qbc.addField(@contactsTableID,field,"text") 
         @clist << "#{id.dup}."
      }
      @clist[-1] = ""
   end
   
   def addSampleData
   
      sampleData = <<ENDSampleData
Fred Davis,434-344-1243,freddavis@internet.com,CEO,DavisCo      
David Fredis,344-434-1243,davidfredis@email.com,Product Manager,Blaxo LLC      
Freda Davis,434-344-1243,fredadavis@internet.com,Technical Lead,Nerds Inc.      
Andy Tabo,454-344-1243,atabo@internet.co.uk,Senior Advisor,Carpet World
Larry Good,334-344-1243,lgood@yahaol.com,VP,Harbor Ventures LLC      
ENDSampleData

      @qbc.importFromCSV(@contactsTableID, @qbc.formatImportCSV(sampleData), @clist)
      
   end
   
   def runRailsCommand
      ret = verifyDirectories
      if runningOnWindows 
         ret = system('rails.bat', @rails_appname) unless ret
         ret = system('rails.cmd', @rails_appname) unless ret
      else
         ret = system('rails', @rails_appname) unless ret
      end        
     ret  
   end
   
   def generateRailsFiles
      #verifyDirectories
      generateModel
      generateViews
      generateController
      generateHelper
      generateDatabaseConfig
      generateRoutes
      renameIndexHTML
    end
    
   def verifyDirectories
       ok = File.directory?("#{@rails_appname}/app/models/")
       ok = File.directory?("#{@rails_appname}/app/views/#{@rails_appname}/") if ok
       ok = File.directory?("#{@rails_appname}/app/controllers/") if ok
       ok = File.directory?("#{@rails_appname}/app/helpers/") if ok
       ok = File.directory?("#{@rails_appname}/config/") if ok
       ok
   end     

   def generateModel

   modelCode = <<ENDModelCode
   
class #{@modelClassName} < ActiveRecord::Base
  def self.listAll
      find_by_sql("#{@contactsTableID}:{'0'.CT.''}")
  end
end

ENDModelCode

      File.open("#{@rails_appname}/app/models/#{@modelFileName}", "w"){|f|f.write(modelCode)}

   end

   def generateViews
      Dir.mkdir("#{@rails_appname}/app/views/#{@rails_appname}/") unless File.directory?("#{@rails_appname}/app/views/#{@rails_appname}/")
      generateListAllView
      generateShowView
      generateNewView
      generateEditView
      generateNewContactForm
      generateEditContactForm
   end
   
   def generateListAllView
   
   listAllCode = <<ENDListAllCode
   
<h1>List All</h1>
<hr>
<% for contact in @contacts do %>
 <%= contact.name %>,<%= contact.phone %>,<%= contact.email %>,<%= contact.title %>,<%= contact.company %>
 <%= link_to 'Show', :action => 'show', :id => contact %>,  
 <%= link_to 'Edit', :action => 'edit', :id => contact %>,  
 <%= link_to 'Destroy', { :action  => 'destroy', :id => contact },  :confirm => 'Are you sure?', :method  => :post %> <hr>
<% end %>
 <%= link_to 'New', :action => 'new' %>
ENDListAllCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/listAll.rhtml", "w" ){|f|f.write(listAllCode)}

   end

   def generateShowView

   showCode = <<ENDShowCode
<h1>Show</h1>
<hr>

<p><b>Name</b> <%= @contact.name %></p>
<p><b>Phone</b> <%= @contact.phone %></p>
<p><b>Email</b> <%= @contact.email %></p>
<p><b>Title</b> <%= @contact.title %></p>
<p><b>Company</b> <%= @contact.company %></p>   
<%= link_to 'Edit', :action => 'edit', :id => @contact %> |
<%= link_to 'Back', :action => 'listAll' %>   
ENDShowCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/show.rhtml", "w" ){|f|f.write(showCode)}

   end

   def generateNewView
   
      newCode = <<ENDNewCode
<h1>New</h1>
<hr>
<% form_tag :action => 'create', :id => @contact do %>  
   <%= render :partial => 'newform' %>  
   <%= submit_tag 'Create' %>
<% end %>
<%= link_to 'Back', :action => 'listAll' %>   
ENDNewCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/new.rhtml", "w" ){|f|f.write(newCode)}

   end

   def generateEditView
   
   editCode = <<EndEditCode
<h1>Edit</h1>
<hr>
<% form_tag :action => 'update', :id => @contact do %>  
   <%= render :partial => 'editform' %>  
   <%= submit_tag 'Edit' %>
<% end %>
<%= link_to 'Show', :action => 'show', :id => @contact %> |
<%= link_to 'Back', :action => 'listAll' %>   
EndEditCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/edit.rhtml", "w" ){|f|f.write(editCode)}

   end

   def generateEditContactForm
   
   formCode = <<ENDFormCode
<p><b>Name</b> <%= text_field 'contact[]', 'name' %></p>
<p><b>Phone</b> <%= text_field 'contact[]', 'phone' %></p>
<p><b>Email</b> <%= text_field 'contact[]', 'email' %></p>
<p><b>Title</b> <%= text_field 'contact[]', 'title' %></p>
<p><b>Company</b> <%= text_field 'contact[]', 'company' %></p>   
ENDFormCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/_editform.rhtml", "w" ){|f|f.write(formCode)}

   end
   
   def generateNewContactForm
   formCode = <<ENDFormCode
<p><b>Name</b> <%= text_field '#{@modelClassName}', 'name' %></p>
<p><b>Phone</b> <%= text_field '#{@modelClassName}', 'phone' %></p>
<p><b>Email</b> <%= text_field '#{@modelClassName}', 'email' %></p>
<p><b>Title</b> <%= text_field '#{@modelClassName}', 'title' %></p>
<p><b>Company</b> <%= text_field '#{@modelClassName}', 'company' %></p>   
ENDFormCode

      File.open("#{@rails_appname}/app/views/#{@rails_appname}/_newform.rhtml", "w" ){|f|f.write(formCode)}

   end

   def generateController
   
   controllerCode = <<ENDControllerCode
class #{@rootClassName}Controller < ApplicationController
  def listAll
    @contacts = #{@modelClassName}.listAll
  end
  def listChanges
    @contacts = #{@modelClassName}.listChanges
  end
  def show
    @contact = #{@modelClassName}.find(params[:id])
  end
  def new
    @contact = #{@modelClassName}.new
  end
  def edit
    @contact = #{@modelClassName}.find(params[:id])
  end
  def destroy
    #{@modelClassName}.find(params[:id]).destroy
   index
  end
  def index
    listAll
    render :action => 'listAll'
  end
  def update
      @contact = #{@modelClassName}.find(params[:id])
      if @contact.update_attributes(params[:contact][params[:id]])
        flash[:notice] = 'Contact was successfully updated.'
        redirect_to :action => 'show', :id => @contact
      else
        render :action => 'edit'
      end
  end
  def create
      @contact = #{@modelClassName}.new(params[:#{@modelClassName}])
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        redirect_to :action => 'listAll'
      else
        render :action => 'new'
      end
  end
end

ENDControllerCode

      File.open( "#{@rails_appname}/app/controllers/#{@rails_appname}_controller.rb", "w" ){|f|f.write(controllerCode)}

   end
   
   def generateHelper
      helperCode = "module #{@rootClassName}Helper\nend\n"
      File.open( "#{@rails_appname}/app/helpers/#{@rails_appname}_helper.rb", "w" ){|f|f.write(helperCode)}
   end
   
   def generateDatabaseConfig

   databaseConfig = <<END_databaseConfig
development:
  adapter: quickbase
  database: #{@rails_appname}
  username: #{@username}
  password: #{@password}
  printRequestsAndResponses: false
  useWorkPlace: #{@useWorkPlace ? "true" : "false"}
  cacheSchemas: true
  decimalPrecision: 38
  host: localhost

# Warning: The database defined as 'test' will be erased and
# re-generated from your development database when you run 'rake'.
# Do not set this db to the same as development or production.
test:
  adapter: quickbase
  database: #{@rails_appname}
  username: #{@username}
  password: #{@password}
  useWorkPlace: #{@useWorkPlace ? "true" : "false"}
  cacheSchemas: true
  decimalPrecision: 38
  host: localhost

production:
  adapter: quickbase
  database: #{@rails_appname}
  username: #{@username}
  password: #{@password}
  cacheSchemas: true
  useWorkPlace: #{@useWorkPlace ? "true" : "false"}
  decimalPrecision: 38
  host: localhost
END_databaseConfig
   
      File.open( "#{@rails_appname}/config/database.yml", "w" ) {|f| f.write( databaseConfig )  }
      
   end
   
   def generateRoutes
   
      routesCode = <<ENDRoutesCode
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "#{@rails_appname}", :action => "listAll"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
ENDRoutesCode
   
      File.open( "#{@rails_appname}/config/routes.rb", "w" ) {|f| f.write( routesCode)  }

   end
   
   def renameIndexHTML
      File.rename( "#{@rails_appname}/public/index.html", "#{@rails_appname}/public/renamed.index.html" ) if File.exist?("#{@rails_appname}/public/index.html")
   end
   
   def displayDoneMsg
      puts "\n\nDone creating the '#{@rails_appname}' application!\n\n"
      puts "Please start 'ruby script/server' in the #{@rails_appname} directory"
      puts "then go to http://localhost:3000/ in your browser.\n\n"
   end
   
   def runningOnWindows
      RUBY_PLATFORM.split("-")[1].include?("mswin")
   end

end

if ARGV[2]
   QuickBaseContactsAppBuilder.new(ARGV[0],ARGV[1],ARGV[2])
elsif ARGV[1]
   QuickBaseContactsAppBuilder.new(ARGV[0],ARGV[1])
else
   puts "usage: ruby QuickBaseContactsAppBuilder.rb username password [useWorkPlace]"
   puts "Creates a very simple Contacts database in QuickBase and a Rails app for it."
   puts "To use workplace.intuit.com instead of www.quickbase.com, add 'useWorkPlace' at the end of the command."
end
