require 'spec_helper'

describe CommentsController do
  include Devise::TestHelpers
  include ControllerMocking

  before(:each) do
    @current_user = mock_user
    @mock_comment = mock_comment
  end

  describe "GET recent" do
	it "should provide most recent comments" do
	  Comment.stub(:recent_comments) { [@mock_comment] }
	  get :recent

	  assigns(:comments).should == [@mock_comment]
	end
  end

  describe "POST create" do
    describe "with valid params" do
      it "saves a new comment to database" do
        Comment.stub(:new).with({'these' => 'params', "user" => @current_user}) { @mock_comment }

        post :create, :format => 'js', :comment => {'these' => 'params'}
        
        assigns(:comment).should be(@mock_comment)
      end
    end

    describe "with duplicate params" do
      it "warns user that the comment was a duplicate" do
        Comment.stub(:new).with({'these' => 'params', "user" => @current_user}) { @mock_comment }
        @mock_comment.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@mock_comment))

        post :create, :format => 'js', :comment => {'these' => 'params'}

        assert_response 409
      end
    end
  end
end
