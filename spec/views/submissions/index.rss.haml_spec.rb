require 'spec_helper'

describe "submissions/index.rss.builder" do
  include Devise::TestHelpers
  include PaginationMocking

  it "renders a list of submissions as a RSS feed" do
    submissions = mock_pagination_of([ObjectMother.create_submission(:title => "Title"), ObjectMother.create_submission(:title => "MyText")])
    assign(:submissions, submissions)

    render

    without_warnings do
      assert_select "item>title", :text => /Title/, :count => 1
      assert_select "item>title", :text => /MyText/, :count => 1
    end
  end
end
