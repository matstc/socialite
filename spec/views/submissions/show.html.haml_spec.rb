require 'spec_helper'

describe "submissions/show.html.haml" do
  include ControllerMocking

  describe "your own submission" do
    before(:each) do
      @current_user = ObjectMother.new_user
      @view.stub(:current_user) {@current_user}
      @submission = ObjectMother.create_submission :user => @current_user
      assign(:submission, @submission)
    end

    it "renders attributes and an edit link" do
      render
      rendered.should match(/#{@submission.title}/)
      rendered.should match(/#{@submission.url}/)
      rendered.should match(/#{@submission.description}/)
      rendered.should match(/Edit your submission/)
    end

    it "should not render a link to mark as spam submission or comment" do
      user = ObjectMother.create_user
      comment = ObjectMother.create_comment :user => user, :submission => @submission
      @submission.comments.should include(comment)

      render

      rendered.should_not match(/mark as spam/)
    end

    it "should render a link to mark submission and comment as spam for admins" do
      user = ObjectMother.create_user
      ObjectMother.create_comment :user => user, :submission => @submission
      @current_user.update_attribute :admin, true

      render

      rendered.should match(/mark as spam/)
    end
  end

  describe "submissions from another user" do
    before(:each) do
      @current_user = ObjectMother.new_user
      @view.stub(:current_user, @current_user)
      @submission = ObjectMother.create_submission
      assign(:submission, @submission)
    end
    it "should not render the edit link if the submission is from another user" do
      rendered.should_not match(/Edit your submission/)
    end
  end
end
