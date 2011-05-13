require 'spec_helper'

describe "admin/tweak_interestingness.html.haml" do
  it "renders the page" do
    render
    assert_select "form", :action => save_interestingness_path, :method => "post" do
    end
  end
end

