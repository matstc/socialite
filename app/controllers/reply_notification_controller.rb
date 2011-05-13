class ReplyNotificationController < ApplicationController
  before_filter :authenticate_user!

  def dismiss_all
    ReplyNotification.delete_all(:user_id => current_user)
    flash[:notice] = "All notifications were dismissed."
    redirect_to(user_path(current_user))
  end

  def destroy
    ReplyNotification.where(:user_id => current_user, :id => params[:id]).first.destroy
    redirect_to(user_path(current_user))
  end
end
