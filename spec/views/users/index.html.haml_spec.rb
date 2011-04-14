require 'spec_helper'

describe "users/index.html.haml" do
  it "renders a list of users" do
    ObjectMother.create_user :username => "michael"
    ObjectMother.create_user :username => "jones"
    assign(:users, User.page(1))
    view.should_receive(:current_user_is_admin?).at_least(1).and_return false
    render

    assert_select "tr>td", :text => /michael/, :count => 1
    assert_select "tr>td", :text => /jones/, :count => 1
  end
end
