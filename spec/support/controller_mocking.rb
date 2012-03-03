require 'spec_helper'

# for more info see https://github.com/plataformatec/devise/wiki/How-To:-Controllers-and-Views-tests-with-Rails-3-%28and-rspec%29
module ControllerMocking
  include Devise::TestHelpers
  include RSpec::Rails::Mocks

  def mock_comment
    mock_model(Comment).as_null_object
  end

  def mock_submission
    mock_model(Submission).as_null_object
  end

  def mock_user options={}
    user = ObjectMother.create_user options
    user.update_attribute :admin, true if options[:admin]
    request.env['warden'] = mock(Warden, :authenticate => user, :authenticate! => user).as_null_object
    user
  end

end
