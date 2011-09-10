require 'spec_helper'

describe Tweet do
  before :each do
    @user = ObjectMother.new_user
    @auth = Authentication.new :provider => :twitter
    @flash = {}
  end
  
  it "should send out a tweet" do
    @user.authentications.should_receive(:find_by_provider).at_least(:once).with(:twitter).and_return(@auth)
    @auth.stub!(:update).and_return(nil)
    @auth.should_receive(:update).with("short message url")

    Tweet.new(@user).update("short message", "url", @flash)

    @flash.should be_empty
  end

  it "should truncate message when too long" do
    @user.authentications.should_receive(:find_by_provider).at_least(:once).with(:twitter).and_return(@auth)
    @auth.stub!(:update).and_return(nil)
    @auth.should_receive(:update).with("#{'x' * 133}... url")

    Tweet.new(@user).update("x" * 140, "url", @flash)

    @flash.should be_empty
  end

  it "should alert the user when url is too long to tweet" do
    @user.authentications.should_receive(:find_by_provider).at_least(:once).with(:twitter).and_return(@auth)
    @auth.should_not_receive(:update)

    Tweet.new(@user).update("short message", "x" * 130, @flash)
    @flash[:alert].should_not be_empty
  end
  
  it "should not do anything if the user is not linked to twitter" do
    user = ObjectMother.new_user
    Tweet.new(user).update("short message", "url", @flash)
    @flash.should be_empty
  end

  it "should handle exceptions when updating" do
    @user.authentications.should_receive(:find_by_provider).at_least(:once).with(:twitter).and_return(@auth)
    @auth.stub!(:update).and_raise(Exception.new "!")
    @auth.should_receive(:update).with("short message url")

    Tweet.new(@user).update("short message", "url", @flash)

    @flash[:alert].should =~ /!/
  end
end

