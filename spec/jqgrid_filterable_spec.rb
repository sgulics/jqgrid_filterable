require File.expand_path('../spec_helper', __FILE__)

describe "jqgrid_filterable" do

  before(:each) do
    load_fixtures
  end

  it "should configure per_page options" do
    User.jqgrid_filterable_options[:per_page].should eql(30)
    User.jqgrid_filterable({:per_page=>100})
    User.jqgrid_filterable_options[:per_page].should eql(100)
  end

  it "should set the columns and special_filters options to empty hash" do
    User.jqgrid_filterable_options[:columns].should eql({}) 
    User.jqgrid_filterable_options[:special_filters].should eql({}) 
  end

  it "should set the include option to empty array" do
    User.jqgrid_filterable_options[:include].should eql([]) 
  end

  it "should really work" do
    puts User.all
  end

end
