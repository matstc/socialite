class CommentsController < ApplicationController
  before_filter :save_post_before_authenticating, :only => [:create]

  def create
    values = params[:comment].merge({:user => current_user})
    @comment = Comment.new values
    @comment.save
    flash[:pre_sign_in_notice] = "Thanks, your comment was received."
    set_html_as_content_type
  end

end
