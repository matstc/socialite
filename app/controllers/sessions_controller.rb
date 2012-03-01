# here we override the devise sessions controller so that we can persist a value across user sessions
class SessionsController < Devise::SessionsController
  respond_to :html

  def destroy
	new_session = session[:new]
    super
	session[:new] = new_session
  end
end
