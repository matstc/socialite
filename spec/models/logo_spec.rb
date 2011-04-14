require 'spec_helper'

class FakeUpload
  attr_accessor :original_filename, :read
  def initialize
    @original_filename = "/a/b/c/test-logo.test"
    @read = ""
  end
end

describe Logo do
  def logo_path
    "public/images/logo.test"
  end

  after(:each) do
    FileUtils.rm_rf(logo_path) if File.exists?(logo_path)
  end

  it "should gather errors in a list" do
    fake_upload = FakeUpload.new
    (class << fake_upload; self; end).send(:define_method, 'read'){ raise "test-exception"}
    logo = Logo.new :image => fake_upload

    logo.save.should == false

    logo.errors.blank?.should == false
    logo.errors[0].should == "test-exception"
    File.exists?(logo_path).should == false
  end

  it "should write new logo to a file" do
    logo = Logo.new :image => FakeUpload.new

    logo.save.should == true
    File.exists?(logo_path).should == true
  end

end
