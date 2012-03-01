require 'spec_helper'

describe 'elevator pitch' do

  before(:each) do
    @user = ObjectMother.create_user
    @submission = ObjectMother.create_submission
  end

  it "should show on first page load -- should not show after the user signs out or signs back in" do
	get root_url
	elevator_pitch_is_shown.should == true
	get root_url
	elevator_pitch_is_shown.should == false

	post_via_redirect user_session_path, :user => {:username => @user.username, :password => '123456'}
	response.status.should == 200
	elevator_pitch_is_shown.should == false

	get_via_redirect destroy_user_session_path
	response.status.should == 200
	elevator_pitch_is_shown.should == false
  end

  def elevator_pitch_is_shown
	response.body.include?("It looks like this is your first time here")
  end

end


