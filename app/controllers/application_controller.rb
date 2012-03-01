class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery
  before_filter :verify_user_is_not_deleted
  before_filter :show_elevator_pitch_if_new_session

  def set_html_as_content_type
    response.headers["Content-Type"] = 'text/html'
  end

  def verify_user_is_not_deleted
	if user_signed_in? and current_user.deleted?
	  logger.info "The account '#{current_user}' was deleted but someone tried to access it" 
	  flash[:alert] = "It looks like your account was deleted. You were probably mistaken for a spammer. Please contact us or register a new account."
	  sign_out current_user
	  redirect_to root_url
	end
  end

  def show_elevator_pitch_if_new_session
	if session[:new].nil? and !user_signed_in?
	  flash.now[:notice] = "Welcome!<br>It looks like this is your first time here.<br>Feel free to share links and take part in the discussion.<br><br>And check out what we are #{self.class.helpers.link_to 'about', about_path}."
	end

	session[:new] = false
  end

  def sign_in_then_redirect
    flash[:alert] = "Please sign in first."
    session[:last_get_url] = params[:current_url]
    redirect_to new_session_url(:user)
  end

  def after_sign_in_path_for resource_or_scope
    last_get_url = session[:last_get_url]
    if last_get_url.nil?
      return super
    end

    # if a post request was saved in the session then we execute it -- see #save_post_before_authenticating
    execute_saved_post_request if session[:pre_sign_in_post]

    last_get_url
  end

  def execute_saved_post_request
    logger.info "Executing the saved POST request before redirecting" 

    begin 
      class_name = session[:pre_sign_in_post][:controller].capitalize + "Controller"
      controller_instance = class_name.constantize.new

      current_request = request
      saved_params = session[:pre_sign_in_post][:params]
      metaclass = (class << controller_instance; self; end)

      # fake the environment of the previous request
      metaclass.send(:define_method, :request) { return current_request }
      metaclass.send(:define_method, :response) { return IdentityProxy.new }
      metaclass.send(:define_method, :params) { return saved_params }
      # prevent rendering at all costs
      metaclass.send(:define_method, :render) {|*args| nil }

      controller_instance.send(session[:pre_sign_in_post][:action])
      flash[:notice] = flash[:pre_sign_in_notice] if flash[:pre_sign_in_notice]
    rescue
      logger.error "An error occurred trying to execute the saved POST request: #{$!}"
      logger.error $!.backtrace.join "\n"
      flash[:alert] = $!.message
    ensure
      session[:pre_sign_in_post] = nil
    end
  end

  # this before filter will save an attempted post request for later execution after the user is authenticated
  def save_post_before_authenticating
    if request.env['warden'].unauthenticated? and request.post?
      logger.info "Will save the POST request for later execution"
      session[:pre_sign_in_post] = {:controller => controller_name, :action => action_name, :params => params.dup}
    end
    
    authenticate_user!
  end

  protected
  def require_admin!
    raise "admins only" if !current_user.try :admin
  end

end
