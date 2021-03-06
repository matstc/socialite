require 'spec_helper'

describe "users/show.html.haml" do
  it "should display the email notifications section if the email was enabled by the admin" do
    user = ObjectMother.create_user
    @view.stub(:current_user) {user}
    assign(:user, user)
	AppSettings.email_enabled = true

    render
    assert_select "h3", :text => /Email notifications/, :count => 1
  end

  it "should not display the email notifications section if the email was not enabled by the admin" do
    user = ObjectMother.create_user
    @view.stub(:current_user) {user}
    assign(:user, user)

    render
    assert_select "h3", :text => /Email notifications/, :count => 0
  end

  it "should display spam notifications to admins" do
    user = ObjectMother.create_user :admin => true
    spam_notitication1 = ObjectMother.create_spam_notification :comment => ObjectMother.create_comment
    spam_notitication2 = ObjectMother.create_spam_notification :submission => ObjectMother.create_submission
    @view.stub(:current_user){user}
    assign(:user, user)
    assign(:spam_notifications, [spam_notitication1, spam_notitication2])

    render

    assert_select ".notifications-box ul>li .notification-text", :text => /spam/, :count => 2
  end

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

  it "should display reply notifications" do
    user = ObjectMother.create_user
    notification = ObjectMother.create_reply_notification :user => user
    user.reload

    @view.stub(:current_user) {user}
    assign(:user, user)
    render

    assert_select ".notifications-box ul>li a", :text => /replied/, :count => 1
  end

  it "should not display notifications of one user to another user" do
    user = ObjectMother.create_user
    notification = ObjectMother.create_reply_notification :user => user
    user.reload

    @view.stub(:current_user) {ObjectMother.create_user}
    assign(:user, user)
    render

    assert_select "ul.notifications>li a", :text => /replied/, :count => 0
  end
end
