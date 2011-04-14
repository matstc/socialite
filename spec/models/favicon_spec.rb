require 'spec_helper'

describe Favicon do
  class FakeUpload
    def read; ""; end
  end

  def favicon_path
    "public/images/favicon.ico.test"
  end

  after(:each) do
    FileUtils.rm_rf(favicon_path) if File.exists?(favicon_path)
  end

  it "should write new favicon to a file" do
    favicon = Favicon.new :image => FakeUpload.new
    favicon.path = favicon_path

    favicon.save.should == true
    File.exists?(favicon_path).should == true
    favicon.errors.blank?.should == true
  end

  it "should gather errors in a list" do
    favicon = Favicon.new :image => Object.new
    favicon.path = "/1/1/1/invalid"

    favicon.save.should == false
    File.exists?(favicon_path).should == false
    favicon.errors.blank?.should == false
  end
end
