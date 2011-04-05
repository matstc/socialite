require 'spec_helper'

describe "admin/index.html.haml" do
  it "renders the list of tasks" do
    render
    assert_select "h1", :text => "Admin tasks"
  end
end


