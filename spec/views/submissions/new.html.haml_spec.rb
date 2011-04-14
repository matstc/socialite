require 'spec_helper'

describe "submissions/new.html.haml" do
  before(:each) do
    assign(:submission, stub_model(Submission,
      :title => "MyString",
      :url => "MyString",
      :description => "MyText").as_new_record)
  end

  it "renders new submission form" do
    render

    assert_select "form", :action => submissions_path, :method => "post" do
      assert_select "input#submission_title", :name => "submission[title]"
      assert_select "input#submission_url", :name => "submission[url]"
      assert_select "textarea#submission_description", :name => "submission[description]"
    end
  end
end
