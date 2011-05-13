class ReplyNotificationController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    ReplyNotification.where(:user_id => current_user, :id => params[:id]).first.destroy

    redirect_to(user_path(current_user))
  end
end
