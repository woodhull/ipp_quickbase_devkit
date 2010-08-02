
require 'spec_workplace_base_test'
require 'spec'

describe "Workplace Edit Record test" do
  
  it "should change a Person record" do
    
    require 'WorkPlaceClient'
    class WorkPlaceEditRecordTest
       include WorkPlaceBaseTest
    end  
    wpert = WorkPlaceEditRecordTest.new 
    workPlaceClient = wpert.setup
    workPlaceClient.should_not == nil

    fn_fid = workPlaceClient.lookupFieldIDByName("First Name", wpert.personTableDBID)
    ln_fid = workPlaceClient.lookupFieldIDByName("Last Name")
    fn_fid.should_not == nil
    ln_fid.should_not == nil

    personFieldValues = Hash["First Name", "FirstName", "Last Name", "LastName"]
    workPlaceClient.setFieldValues(personFieldValues)
    rid, update_id = workPlaceClient.addRecord(wpert.personTableDBID,workPlaceClient.fvlist)
    rid.should_not == nil

    personFieldValues = Hash["First Name", "NewFirstName", "Last Name", "NewLastName"]
    workPlaceClient.setFieldValues(personFieldValues) # does editRecord re-using last dbid and rid
    
    workPlaceClient._getRecordInfo(rid)
    fn = workPlaceClient.getFieldDataValue(fn_fid)
    ln = workPlaceClient.getFieldDataValue(ln_fid)
    fn.should == "NewFirstName"
    ln.should == "NewLastName"

  end
  
end
