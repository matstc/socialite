require 'spec_helper'

describe "users/show_votes.html.haml" do
  it "should show no votes if user has not voted anything yet" do
    user = ObjectMother.create_user
    @view.stub(:current_user){user}
    assign(:user, user)

    render

    assert_select "p", :text => /#{user.username} voted up 0 submissions/
  end

  it "should show a vote if user voted up something" do
    user = ObjectMother.create_user
    vote = ObjectMother.create_vote user, ObjectMother.create_submission
    @view.stub(:current_user){user}
    assign(:user, user)

    render

    assert_select "p", :text => /#{user.username} voted up 1 submission/
  end

end
