require 'spec_helper'

describe FaviconsController do
  include Devise::TestHelpers
  include ControllerMocking

  before(:each) do
    @mock_user = mock_user :admin => true
  end

  def mock_favicon(stubs={})
    @mock_favicon ||= mock(Favicon, stubs)
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created favicon as @favicon" do
        Favicon.stub(:new).with({'these' => 'params'}) { mock_favicon(:save => true) }
        post :create, :favicon => {'these' => 'params'}
        assigns(:favicon).should be(mock_favicon)
      end

      it "redirects to the new favicon url" do
        Favicon.stub(:new) { mock_favicon(:save => true) }
        post :create, :favicon => {}
        response.should redirect_to(new_logo_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved favicon as @favicon" do
        favicon = mock_favicon(:save => false)
        Favicon.stub(:new).with({'these' => 'params'}) { favicon }
        favicon.should_receive(:errors)

        post :create, :favicon => {'these' => 'params'}
        assigns(:favicon).should be(mock_favicon)
      end

      it "re-renders the 'new' template" do
        favicon = mock_favicon(:save => false)
        Favicon.stub(:new) { favicon }
        favicon.should_receive(:errors)

        post :create, :favicon => {}
        response.should render_template("new")
      end
    end
  end

end
