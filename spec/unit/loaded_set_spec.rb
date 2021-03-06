require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

require ROOT_DIR + 'lib/data_mapper/repository'
require ROOT_DIR + 'lib/data_mapper/resource'
require ROOT_DIR + 'lib/data_mapper/loaded_set'

describe "DataMapper::LoadedSet" do

  before :all do
    DataMapper.setup(:default, "mock://localhost/mock") unless DataMapper::Repository.adapters[:default]

    @cow = Class.new do
      include DataMapper::Resource

      property :name, String, :key => true
      property :age, Fixnum
    end
  end

  it "should be able to add arbitrary objects" do
    properties              = @cow.properties(:default)
    properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]

    set = DataMapper::LoadedSet.new(DataMapper::repository(:default), @cow, properties_with_indexes)
    set.should respond_to(:reload!)

    set.add(['Bob', 10])
    set.add(['Nancy', 11])

    results = set.entries
    results.should have(2).entries

    results.each do |cow|
      cow.instance_variables.should include('@name')
      cow.instance_variables.should include('@age')
    end

    bob, nancy = results[0], results[1]

    bob.name.should eql('Bob')
    bob.age.should eql(10)
    bob.should_not be_a_new_record

    nancy.name.should eql('Nancy')
    nancy.age.should eql(11)
    nancy.should_not be_a_new_record

    results.first.should == bob
  end

end

describe "DataMapper::LazyLoadedSet" do

  before :all do
    DataMapper.setup(:default, "mock://localhost/mock") unless DataMapper::Repository.adapters[:default]

    @cow = Class.new do
      include DataMapper::Resource

      property :name, String, :key => true
      property :age, Fixnum
    end

    properties               = @cow.properties(:default)
    @properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
  end

  it "should raise an error if no block is provided" do
    lambda { set = DataMapper::LazyLoadedSet.new(DataMapper::repository(:default), @cow, @properties_with_indexes) }.should raise_error
  end

  it "should make a materialization block" do
    set = DataMapper::LazyLoadedSet.new(DataMapper::repository(:default), @cow, @properties_with_indexes) do |lls|
      lls.add(['Bob', 10])
      lls.add(['Nancy', 11])
    end

    set.instance_variable_get("@entries").should be_empty
    results = set.entries
    results.size.should == 2
  end

  it "should be eachable" do
    set = DataMapper::LazyLoadedSet.new(DataMapper::repository(:default), @cow, @properties_with_indexes) do |lls|
      lls.add(['Bob', 10])
      lls.add(['Nancy', 11])
    end

    set.each do |x|
      x.name.should be_a_kind_of(String)
    end
  end
end
