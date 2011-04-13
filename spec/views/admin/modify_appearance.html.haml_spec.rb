require 'spec_helper'

describe "admin/modify_appearance.html.haml" do
  it "renders the page" do
    assign(:themes, [])
    render
    assert_select "form", :action => save_appearance_path, :method => "post" do
    end
  end
end

