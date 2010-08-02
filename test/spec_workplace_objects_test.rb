
require 'spec_workplace_base_test'
require 'spec'

describe "Workplace Objects test" do
  
  it "should create a valid Person Table object" do
    
    require 'WorkPlaceClient'
    class WorkPlaceObjectsTest
       include WorkPlaceBaseTest
    end  
    wpot = WorkPlaceObjectsTest.new 
    workPlaceClient1 = wpot.setup
    
    require 'QuickBaseObjects'
    workPlaceClient2 = QuickBase::WorkPlaceClient.new(workPlaceClient1.username,workPlaceClient1.password)
    workPlaceClient2.should_not == nil
    workPlaceClient2.apptoken=workPlaceClient1.apptoken
    
    ob = QuickBase::Objects::Builder.new(nil,nil,workPlaceClient2)
    ob.should_not == nil
    
    test_app = ob.application(wpot.testAppName)
    
    test_app.should_not == nil
    test_app.tPersons.should_not == nil
    
    fields_ok = true 
    person_field_names = wpot.personFields.keys
    test_app.tPersons.fields.each{|fid,field|
      next if workPlaceClient2.isBuiltInField?(fid)
      fields_ok = false if ! person_field_names.include?(field.properties["label"])
    }
    fields_ok.should == true
    
  end
  
end
