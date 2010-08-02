
require 'spec_workplace_base_test'
require 'spec'

describe "WorkPlace Smoke Test" do
  
  it "should find the WorkPlaceClient.rb file" do
    found = require 'WorkPlaceClient'
    found.should == true
  end  
  
  it "should create a WorkPlaceClient" do
    require 'WorkPlaceClient'
    wpc = QuickBase::WorkPlaceClient.new
    wpc.should_not == nil
  end  
  
  it "should show that the workplace client points at the right host" do
    require 'WorkPlaceClient'
    wpc = QuickBase::WorkPlaceClient.new
    wpc.org.should == "workplace"
    wpc.domain.should == "intuit"
  end  
  
  it "should add a Person table to an existing workplace application" do
    require 'WorkPlaceClient'
    class WorkPlaceSmokeTest
       include WorkPlaceBaseTest
    end  
    wpst = WorkPlaceSmokeTest.new 
    wpst.setup
    wpst.workPlaceClient.should_not == nil
    wpst.testAppDBID.should_not == nil
    wpst.personTableDBID.should_not == nil
    wpst.personFields.should_not == nil
    wpst.workPlaceClient.getSchema(wpst.personTableDBID)
    testFailed = false
    wpst.personFields.each{|fieldName,fieldType|
      fid = wpst.workPlaceClient.lookupFieldIDByName(fieldName)
      testFailed = true if !fid
    }
    testFailed.should == false
  end  
  
end  
