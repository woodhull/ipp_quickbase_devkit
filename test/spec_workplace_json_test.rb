
require 'spec_workplace_base_test'
require 'spec'

describe "Workplace JSON test" do
  
  it "should get records in JSON format" do
    
    require 'WorkPlaceClient'
    class WorkPlaceJSONTest
       include WorkPlaceBaseTest
    end  
    wpjt = WorkPlaceJSONTest.new 
    workPlaceClient = wpjt.setup
    workPlaceClient.should_not == nil

    person1 = Hash["First Name", "Fred", "Last Name", "Flintstone"]
    workPlaceClient.setFieldValues(person1, false)
    workPlaceClient.addRecord(wpjt.personTableDBID,workPlaceClient.fvlist)

    person2 = Hash["First Name", "Wilma", "Last Name", "Flintstone"]
    workPlaceClient.setFieldValues(person2, false)
    workPlaceClient.addRecord(wpjt.personTableDBID,workPlaceClient.fvlist)

    person3 = Hash["First Name", "Barney", "Last Name", "Rubble"]
    workPlaceClient.setFieldValues(person3, false)
    workPlaceClient.addRecord(wpjt.personTableDBID,workPlaceClient.fvlist)
  
    jsonRecords = workPlaceClient.getAllValuesForFieldsAsJSON(wpjt.personTableDBID,["First Name", "Last Name"])
    jsonRecords.should_not == nil
    
    rubyRecords = JSON.parse(jsonRecords)
    b = rubyRecords.include?(person1) and rubyRecords.include?(person2) and rubyRecords.include?(person3)
    b.should == true
      
  end
  
end
