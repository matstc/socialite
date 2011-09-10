class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    auth = request.env["omniauth.auth"]

    if auth.blank?
      flash[:alert] = "We could not link your Twitter account. The response we received from the Twitter service was unexpected. Please try again in a few minutes."
      redirect_to user_url(current_user)
      return
    end
    
    authentication = current_user.authentications.find_by_provider_and_uid(auth['provider'], auth['uid'])
    authentication = Authentication.new({:user_id => current_user.id, :provider => auth['provider'], :uid => auth['uid']}) if authentication.nil?
    authentication.update_attributes! auth['credentials']

    flash[:notice] = "Your account is now linked to #{auth['provider'].capitalize}."
    redirect_to user_url(current_user)
  end

  def failed
    flash[:alert] = "The authorization failed. Please try again in a few minutes. The error message was: #{params[:message]}"
    redirect_to user_url(current_user)
  end

  def destroy
    @authentication = current_user.authentications.find_by_id(params[:id])
    if @authentication.nil?
      flash[:notice] = "Your account is no longer linked." 
    else
      flash[:notice] = "Your account is no longer linked to #{@authentication.provider.capitalize}." 
      @authentication.destroy
    end
    redirect_to user_url(current_user)
  end

end
