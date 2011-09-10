require 'spec_helper'

describe Authentication do
  it "should update the twitters" do
    auth = Authentication.new :provider => 'twitter', :token => 't', :secret => 's'
    AppSettings['twitter_consumer_key'] = 'consumer_key'
    AppSettings['twitter_consumer_secret'] = 'consumer_secret'

    mock_twitter_client = mock(Twitter::Client)
    Twitter::Client.stub!(:new){mock_twitter_client}
    mock_twitter_client.should_receive(:update).with("message")

    auth.update "message"
  end

  it "should raise an exception when provider is not supported" do
    auth = Authentication.new :provider => 'junk'
    lambda {auth.update "!"}.should raise_error
  end
end

