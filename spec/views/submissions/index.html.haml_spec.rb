require 'spec_helper'

describe "submissions/index.html.haml" do
  include Devise::TestHelpers
  include PaginationMocking

  it "renders a list of submissions" do
    submissions = mock_pagination_of([ObjectMother.create_submission(:title => "Title"), ObjectMother.create_submission(:title => "MyText")])
    assign(:submissions, submissions)
    render

    assert_select "tr>td", :text => /Title/, :count => 1
    assert_select "tr>td", :text => /MyText/, :count => 1
  end
end
