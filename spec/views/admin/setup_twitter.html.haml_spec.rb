require 'spec_helper'

describe "admin/setup_twitter.html.haml" do
  it "renders the page" do
    render
    assert_select "form", :action => :save_twitter, :method => "post" do
    end
  end
end

