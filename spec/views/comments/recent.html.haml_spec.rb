require 'spec_helper'

describe "comments/recent.html.haml" do
  include ControllerMocking

  before(:each) do
    @mock_comment = ObjectMother.create_comment
	assign(:comments, [@mock_comment])
  end

  it "should render recent comments" do
	render
	assert_select "ul li div", :text => @mock_comment.text, :count => 1
  end
end


