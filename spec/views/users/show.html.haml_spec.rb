require 'spec_helper'

describe "users/show.html.haml" do

  it "should indicate that the profile text was not provided" do
    user = ObjectMother.create_user :profile_text => nil
    @view.stub(:current_user) {user}
    assign(:user, user)

    render

    assert_select "p", :text => /You did not provide/, :count => 1
  end

  it "renders the profile of user" do
    user = ObjectMother.create_user :profile_text => "this is some profile text"
    @view.stub(:current_user) {user}
    assign(:user, user)

    render

    assert_select "p", :text => /this is some profile text/, :count => 1
  end
end
