require 'spec_helper'

describe IdentityProxy do

  it "should return self for any method that is not defined" do
    proxy = IdentityProxy.new
    proxy.a.a.a.should == proxy
  end

  it "should still remain itself even when calling a method that assigns a value" do
    proxy = IdentityProxy.new
    proxy.something['dsa'] = true
    proxy.a.a.a.should == proxy
  end
end

