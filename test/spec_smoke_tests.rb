
require 'spec'

describe "Smoke Test" do

  it "should show that the basic ruby files are in the regular ruby paths" do
      found = false
      $:.each{|path| found = true if File.exist?("#{path}/date.rb") }
      found.should == true
  end  

  it "should show that the main ipp_quickbase_devkit src file is not in the regular ruby paths" do
      found = false
      $:.each{|path| found = true if File.exist?("#{path}/QuickBaseClient.rb") } unless ruby19?
      found.should == false
  end  

  it "should show that the main ipp_quickbase_devkit src file is not loaded by default" do
      found = false
      $".each{|path| found = true if path.include? "QuickBaseClient.rb" }
      found.should == false
  end  
  
  it "should find ipp_quickbase_devkit" do
    found = require 'QuickBaseClient'
    found.should == true
  end
  
  it "should create a QuickBase::Client" do
    qbc_required = require 'QuickBaseClient'
    qbc =  QuickBase::Client.new
    qbc.should_not == nil
  end
  
  it "should create a QuickBase::CommandLineClient" do
    require 'QuickBaseCommandLineClient'
    qbc =  QuickBase::CommandLineClient.new
    qbc.should_not == nil
  end
  
  it "should create a QuickBase::WebClient" do
    require 'QuickBaseWebClient'
    qbc =  QuickBase::WebClient.new(false)
    qbc.should_not == nil
  end

  it "should show that the gem searching is turned on" do
      gemSearching = ENV["RUBYOPT"].include? "-rubygems"
      gemSearching.should == true
  end  

  it "should NOT find ipp_quickbase_devkit when -rubygems option is off" do
    ENV["RUBYOPT"]=""
    found = require 'QuickBaseClient'
    found.should == false
  end

end
