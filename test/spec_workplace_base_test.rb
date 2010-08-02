
module WorkPlaceBaseTest

  attr_reader :workPlaceClient, :testAppDBID, :testAppName, :personTableDBID, :personFields 

  def setup

    if not File.exist?("test.config")
      File.open("test.config","w"){|f|
         f.puts("username:<enter your workplace username>")
         f.puts("password:<enter your workplace password>")
         f.puts("appname:<enter the name of an existing test application, e.g. MyTestApp>")
         f.puts("apptoken:<enter a valid application token for your test application>")
         raise "***Please fill out the fields in test.config***"
      }
    end  

    @options = {}
    #@options["printRequestsAndResponses"]=true
    @options["stopOnError"]=true
    IO.foreach("test.config"){|line|
      key,value = line.split(/:/)
      @options[key]=value.strip if key and value
    }
    
    raise "'username' missing from test.config" if !@options["username"]
    raise "'password' missing from test.config" if !@options["password"]
    raise "'appname' missing from test.config"  if !@options["appname"]
    raise "'apptoken' missing from test.config" if !@options["apptoken"]
    
    @workPlaceClient = QuickBase::WorkPlaceClient.init(@options)
    
    #@workPlaceClient.printRequestsAndResponses=true
    
    @workPlaceClient.grantedDBs().each{|dbinfo| @testAppDBID = dbinfo.dbid if dbinfo.dbname == @options["appname"] }
    
    @testAppName = "Test copy of #{@options['appname']}"
    @workPlaceClient.grantedDBs().each{|dbinfo| @workPlaceClient.deleteDatabase(dbinfo.dbid) if dbinfo.dbname == @testAppName }
    @testAppDBID = @workPlaceClient.cloneDatabase(@testAppDBID, @testAppName, @testAppName, true) if @testAppDBID
    
    @testAppName = @options['appname'] unless @testAppDBID
    @testAppDBID = @workPlaceClient.createDatabase(@options["appname"],@options["appname"]) unless @testAppDBID
    
    raise "Unable to clone or create an application with the name #{@options['appname']}" unless @testAppDBID
    
    @personsTableName = "Persons"
    @personTableDBID = @workPlaceClient.createTable(@personsTableName, @testAppDBID)
    @personFields = Hash["First Name", "text", "Last Name", "text", "Email", "email","Image","file","Web Page","url","Opt In","checkbox","DOB","date","Attention Span","duration","Favorite Number","float","Favorite Number Squared","float","Amount Owed", "currency","Rating", "rating","PhoneNumber", "phone","Bedtime", "timeofday","Address", "text"]
    @personFields.each{|name,type|
      fid,label = @workPlaceClient.addField(@personTableDBID,name,type)
      @workPlaceClient.setFieldProperties(@personTableDBID,{"formula" => "[Favorite Number] * [Favorite Number]"},fid) if name == "Favorite Number Squared"
      @workPlaceClient.setFieldProperties(@personTableDBID,{"num_lines" => "3"},fid) if name == "Address"
    }
    @workPlaceClient
  end  
  
end
