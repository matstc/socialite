require 'spec_helper'

describe "users/best_of.html.haml" do
  include ControllerMocking

  it "renders the list of users for user that is not admin" do
    ObjectMother.create_user :username => "michael"
    ObjectMother.create_user :username => "jones"
    assign(:users, User.page(1))
    view.should_receive(:current_user_is_admin?).at_least(1).and_return false
    render

    assert_select "tr>td", :text => /michael/, :count => 1
    assert_select "tr>td", :text => /jones/, :count => 1

    rendered.should_not match /delete/
    rendered.should_not match /edit/
  end

  it "renders a delete and edit link for admins" do
    ObjectMother.create_user :username => "michael"
    ObjectMother.create_user :username => "jones"
    assign(:users, User.page(1))
    view.should_receive(:current_user_is_admin?).at_least(1).and_return true
    render

    rendered.should match /delete/
    rendered.should match /edit/
  end
end
