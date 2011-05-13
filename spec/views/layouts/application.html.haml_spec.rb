require 'spec_helper'

describe 'layouts/application.html.haml' do
  it "should render a mail icon if the user has reply notifications" do
    user = ObjectMother.create_user
    comment = ObjectMother.create_comment
    ObjectMother.create_reply_notification :user => user, :comment => comment
    user.reload
    @view.stub(:current_user) {user}
    render

    assert_select ".ui-icon-mail-closed", :count => 1
  end

  it "should not render a mail icon if the user has no reply notifications" do
    user = ObjectMother.create_user
    @view.stub(:current_user) {user}
    render

    assert_select ".ui-icon-mail-closed", :count => 0
  end

end
