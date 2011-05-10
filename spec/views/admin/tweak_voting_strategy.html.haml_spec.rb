require 'spec_helper'

describe "admin/tweak_voting_strategy.html.haml" do
  it "renders the page" do
    render
    assert_select "form", :action => save_voting_strategy_path, :method => "post" do
    end
  end
end

