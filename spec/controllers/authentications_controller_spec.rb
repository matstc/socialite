require 'spec_helper'

describe AuthenticationsController do
  include Devise::TestHelpers
  include ControllerMocking

  before(:each) do
    @user = mock_user
  end

  it "should alert the user when the authentication failed" do
    get :failed
    flash[:alert].should_not be_empty
  end

  it "should create an authentication to twitter" do
    request.env["omniauth.auth"] = {'provider' => 'test-provider', 'uid' => 'uid', 'credentials' => {'token' => 't', 'secret' => 's'}}

    post :create, :provider => 'test-provider'

    Authentication.find_by_provider('test-provider').uid.should == 'uid'
    Authentication.find_by_provider('test-provider').provider.should == 'test-provider'
    Authentication.find_by_provider('test-provider').token.should == 't'
    Authentication.find_by_provider('test-provider').secret.should == 's'
    flash[:notice].should == "Your account is now linked to Test-provider."
  end

  it "should alert the user if the omniauth token could not be found" do
    post :create, :provider => 'test-provider'
    flash[:alert].should_not be_empty
  end

  it "should destroy the authentication" do
    auth = Authentication.new :provider => 'p', :uid => 'u', :token => 't', :secret => 's'
    @user.authentications << auth
    @user.save!
    delete :destroy, :id => auth.id

    Authentication.find_by_id(auth.id).should be_nil
  end

  it "should not fail when the authentication cannot be found" do
    delete :destroy, :id => 123
    flash[:notice].should_not be_empty
  end

end
