require 'spec_helper'

describe UsersController do
  include ControllerMocking

  before(:each) do
    @mock_user = mock_user :admin => true
  end

  describe "spammers" do
    it "assigns the spammers to @users" do
      spammer = ObjectMother.create_user
      ObjectMother.create_submission :user => spammer, :is_spam => true

      get :spammers
      assigns(:users).should == [spammer]
    end
  end

  describe "best of" do
    it "assigns the best users of all time to @users" do
      get :best_of
      assigns(:users).should == [@mock_user]
    end
  end

  describe "GET index" do
    it "assigns all users as @users" do
      User.stub(:page) { [@mock_user] }
      get :index
      assigns(:users).should eq([@mock_user])
    end
  end

  describe "GET show" do
    it "assigns the requested users as @user" do
      User.stub(:find).with("37") { @mock_user }
      get :show, :id => "37"
      assigns(:user).should be(@mock_user)
    end
  end

  describe "GET new" do
    it "assigns a new users as @user" do
      User.stub(:new) { @mock_user }
      get :new
      assigns(:user).should be(@mock_user)
    end
  end

  describe "GET edit" do
    it "assigns the requested users as @user" do
      User.stub(:find).with("37") { @mock_user }
      get :edit, :id => "37"
      assigns(:user).should be(@mock_user)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created user as @user" do
        User.stub(:new).with({'these' => 'params'}) { @mock_user }
        post :create, :user => {'these' => 'params'}
        assigns(:user).should be(@mock_user)
      end

      it "redirects to the created user" do
        User.stub(:new) { @mock_user.stub(:save => true); @mock_user }
        post :create, :user => {}
        response.should redirect_to(user_url(@mock_user))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        User.stub(:new).with({'these' => 'params'}) { @mock_user.stub(:save => false); @mock_user }
        post :create, :user => {'these' => 'params'}
        assigns(:user).should be(@mock_user)
      end

      it "re-renders the 'new' template" do
        User.stub(:new) { @mock_user.stub(:save => false); @mock_user }
        post :create, :user => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested users" do
        User.stub(:find).with("37") { @mock_user }
        @mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {'these' => 'params'}
      end

      it "assigns the requested user as @user" do
        User.stub(:find) { @mock_user }
        put :update, :id => "1", :user => {}
        assigns(:user).should be(@mock_user)
      end

      it "redirects to the user profile" do
        User.stub(:find) { @mock_user }
        put :update, :id => "1", :user => {}
        response.should redirect_to(user_path(@mock_user))
      end

      it "does not update the admin flag if the user is not admin" do
        @mock_user.update_attribute :admin, false
        User.stub(:find) {@mock_user}
        put :update, :id => "1", :user => {:admin => "1"}

        @mock_user.admin.should == false
      end

      it "does not update another user's attributes if the user is not admin" do
        @mock_user.update_attribute :admin, false
        @other_user = ObjectMother.create_user :username => "another_user"
        User.stub(:find) {@other_user}

        lambda { put :update, :id => @other_user.id, :user => {:username => "wacko"} }.should raise_error
      end

      it "should not allow a non-admin user to a update his username" do
        @mock_user.update_attribute :admin, false
        @mock_user.update_attribute :username, "original"
        User.stub(:find) {@mock_user}

        put :update, :id => @mock_user.id, :user => {:username => "wacko", :profile_text => "new profile text"}
        @mock_user.username.should == "original"
        @mock_user.profile_text.should == "new profile text"
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        @mock_user.stub(:update_attributes => false)
        User.stub(:find) { @mock_user }
        put :update, :id => "1", :user => {}
        assigns(:user).should be(@mock_user)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = ObjectMother.create_user
      delete :destroy, :id => user.id
      user.reload
      user.deleted?.should == true
      response.should redirect_to(users_path)
    end
  end
end
