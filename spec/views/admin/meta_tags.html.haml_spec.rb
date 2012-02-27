require 'spec_helper'

describe "admin/meta_tags.html.haml" do
  it "renders the page" do
    render
    assert_select "form", :action => :save_meta_tags, :method => "post" do
    end
  end
end

