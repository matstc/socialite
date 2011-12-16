require 'spec_helper'

describe SubmissionsController do
  include ControllerMocking

  before(:each) do
    @current_user = mock_user
    @mock_submission = mock_submission
    Antispam.stub(:new){mock(Antispam, {:is_spam? => true}).as_null_object}
  end

  describe "most recent" do
    it "assigns submissions by calling most recent" do
      Submission.stub(:page) { [@mock_submission] }
      get :most_recent
      assigns(:submissions).should eq([@mock_submission])
    end
  end

  describe "best of" do
    it "assigns submissions by calling best of" do
      Submission.stub(:page) { [@mock_submission] }
      get :best_of
      assigns(:submissions).should eq([@mock_submission])
    end
  end

  describe "GET index" do
    it "assigns first page of submissions as @submissions" do
      Submission.stub(:page) { [@mock_submission] }
      get :index
      assigns(:submissions).should eq([@mock_submission])
    end
  end

  describe "GET show" do
    it "assigns the requested submission as @submission" do
      Submission.unscoped.stub(:find).with("37") { @mock_submission }
      get :show, :id => "37"
      assigns(:submission).should be(@mock_submission)
    end
  end

  describe "GET new" do
    it "assigns a new submission as @submission" do
      Submission.stub(:new) { @mock_submission }
      get :new
      assigns(:submission).should be(@mock_submission)
    end

    it "assigns values from params" do
      submission = Submission.new :url => 'test-url'
      get :new, :submission => {:url => 'test-url'}
      assigns(:submission).url.should  == submission.url
    end
  end

  describe "GET edit" do
    it "assigns the requested submission as @submission" do
      submission = ObjectMother.create_submission :user => @current_user
      get :edit, :id => submission.id
      assigns(:submission).should == submission
    end

    it "should not allow fellow user to edit submission" do
      submission = ObjectMother.create_submission :user => ObjectMother.create_user
      lambda { get :edit, :id => submission.id }.should raise_error
    end

    it "should always allow admin to edit submission" do
      @current_user.update_attribute :admin, true
      submission = ObjectMother.create_submission :user => ObjectMother.create_user
      get :edit, :id => submission.id
      assigns(:submission).should == submission
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created submission as @submission" do
        Submission.stub(:new).with({'these' => 'params', "user" => @current_user}) { @mock_submission }
        post :create, :submission => {'these' => 'params'}
        assigns(:submission).should be(@mock_submission)
      end

      it "redirects to the created submission" do
        Submission.stub(:new) { @mock_submission.stub(:save => true); @mock_submission }
        post :create, :submission => {}
        response.should redirect_to(submission_url(@mock_submission))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved submission as @submission" do
        Submission.stub(:new).with({'these' => 'params', "user" => @current_user}) { @mock_submission.stub(:save => false); @mock_submission }
        post :create, :submission => {'these' => 'params'}
        assigns(:submission).should be(@mock_submission)
      end

      it "re-renders the 'new' template" do
        Submission.stub(:new) { @mock_submission.stub(:save => false); @mock_submission }
        post :create, :submission => {}
        response.should render_template("new")
      end
    end

    describe "creating a spam submission" do
      it "should mark a spam submission as such and create a spam notification" do
        Submission.stub(:new).with({"user" => @current_user}) {@mock_submission}
        @mock_submission.should_receive :mark_as_spam
        @mock_spam_notification = mock(SpamNotification)
        SpamNotification.stub(:new).with({:submission => @mock_submission}) {@mock_spam_notification}
        @mock_spam_notification.should_receive :save!
        post :create, :submission => {}
      end

      it "does not save a spam notification unless the submission was actually valid and saved" do
        invalid_submission = mock_submission
        invalid_submission.stub!(:save).and_return(false)
        Submission.stub(:new).with({"user" => @current_user}) {invalid_submission}
        SpamNotification.stub(:new) {raise "SpamNotification#new should not have been called"}
        post :create, :submission => {}
      end
    end

  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested submission" do
        Submission.stub(:find).with("37") { @mock_submission }
        @mock_submission.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :submission => {'these' => 'params'}
      end

      it "assigns the requested submission as @submission" do
        Submission.stub(:find) { @mock_submission }
        put :update, :id => "1"
        assigns(:submission).should be(@mock_submission)
      end

      it "redirects to the submission" do
        Submission.stub(:find) { @mock_submission }
        put :update, :id => "1"
        response.should redirect_to(submission_url(@mock_submission))
      end
    end

    describe "with invalid params" do
      it "assigns the submission as @submission" do
        Submission.stub(:find) { @mock_submission.stub(:update_attributes => false); @mock_submission }
        put :update, :id => "1"
        assigns(:submission).should be(@mock_submission)
      end

      it "re-renders the 'edit' template" do
        Submission.stub(:find) { @mock_submission.stub(:update_attributes => false); @mock_submission }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested submission" do
      Submission.stub(:find).with("37") { @mock_submission }
      @mock_submission.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the submissions list" do
      Submission.stub(:find) { @mock_submission }
      delete :destroy, :id => "1"
      response.should redirect_to(submissions_url)
    end
  end

end
