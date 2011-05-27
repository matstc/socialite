require 'spec_helper'

describe "admin/setup_google_analytics.html.haml" do
  it "renders the page" do
    render
    assert_select "form", :action => :save_google_analytics, :method => "post" do
    end
  end
end

