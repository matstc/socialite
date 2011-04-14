require 'spec_helper'

class FakeUpload
  def read
    ""
  end
end

describe Favicon do
  def favicon_path
    "public/images/favicon.ico.test"
  end

  after(:each) do
    FileUtils.rm_rf(favicon_path) if File.exists?(favicon_path)
  end

  it "should write new favicon to a file" do
    favicon = Favicon.new :image => FakeUpload.new
    favicon.path = favicon_path
    favicon.save
    File.exists?(favicon_path).should == true
  end
end
