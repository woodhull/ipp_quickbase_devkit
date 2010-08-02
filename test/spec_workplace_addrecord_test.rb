
require 'spec_workplace_base_test'
require 'spec'

describe "Workplace Add Record test" do
  
  it "should add a Person" do
    
    require 'WorkPlaceClient'
    class WorkPlaceAddRecordTest
       include WorkPlaceBaseTest
    end  
    wpart = WorkPlaceAddRecordTest.new 
    workPlaceClient = wpart.setup
    workPlaceClient.should_not == nil
    
    personFieldValues = Hash["First Name", "FirstName", "Last Name", "LastName", "Email", "FirstNameLastName@email.com","Web Page","http://www.FirstNameLastName.com","Opt In","1","DOB","12-12-1978","Attention Span","1","Favorite Number","7","Amount Owed", "34.87","Rating", "4","PhoneNumber", "454-323-3456","Bedtime", "23","Address", "10 Downing Street"]
    workPlaceClient.setFieldValues(personFieldValues)
    rid, update_id = workPlaceClient.addRecord(wpart.personTableDBID,workPlaceClient.fvlist)
    rid.should_not == nil
    
  end

  it "should add a Person with an Image file attachment" do
    
    require 'WorkPlaceClient'
    class WorkPlaceAddRecordTest
       include WorkPlaceBaseTest
    end  
    wpart = WorkPlaceAddRecordTest.new 
    workPlaceClient = wpart.setup
    workPlaceClient.should_not == nil
    
    workPlaceClient.addFieldValuePair("First Name",nil,nil,"Whatever")
    workPlaceClient.addFieldValuePair("Last Name",nil,nil,"Works")
    workPlaceClient.addFieldValuePair("Image",nil,"FileName","File Contents") # contents from memory 
    rid, update_id = workPlaceClient.addRecord(wpart.personTableDBID,workPlaceClient.fvlist)
    rid.should_not == nil
    
    fid = workPlaceClient.lookupFieldIDByName("Image", wpart.personTableDBID)
    response, filecontents = workPlaceClient._downLoadFile(rid,fid)
    filecontents.should == "File Contents"
    
  end

end
