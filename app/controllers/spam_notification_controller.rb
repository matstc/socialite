class SpamNotificationController < ApplicationController
  before_filter :require_admin!

  def dismiss_all
    SpamNotification.delete_all
    flash[:notice] = "All spam notifications were dismissed."
    redirect_to(user_path(current_user))
  end

  def destroy
    notification = SpamNotification.where(:id => params[:id]).first
    notification.destroy if !notification.nil?
    redirect_to(user_path(current_user))
  end
end
