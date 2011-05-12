require 'spec_helper'

describe "users/edit.html.haml" do
  before(:each) do
    @user = assign(:users, stub_model(User))
    @view.stub(:current_user) {@user}
  end

  it "renders the edit user form with inputs for the username if user is admin" do
    @user.admin = true
    render

    assert_select "form", :action => user_path(@user), :method => "post" do
      assert_select "textarea#user_profile_text", :name => "user[profile_text]"
      assert_select "input#user_username", :name => "user[username]"
      assert_select "input#user_admin", :name => "user[admin]"
    end
  end

  it "renders the edit user form without inputs for the username and admin if user is not admin" do
    render

    assert_select "form", :action => user_path(@user), :method => "post" do
      assert_select "textarea#user_profile_text", :name => "user[profile_text]"
      assert_select "input#user_username", :name => "user[username]", :count => 0
      assert_select "input#user_admin", :name => "user[admin]", :count => 0
    end
  end
end
