class SubmissionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :best_of, :vote_up, :most_recent]
  before_filter :save_post_before_authenticating, :only => [:vote_up]

  def best_of
    @submissions = Submission.best_of.page params[:page]
  end

  def most_recent
    @submissions = Submission.most_recent.page params[:page]
  end

  # POST /submissions/1/vote_up
  def vote_up
    @submission = Submission.find(params[:id])
    @submission.vote_up current_user
    flash[:pre_sign_in_notice] = "Thanks, your vote was acknowledged."
    render :text => "({id: #{@submission.id}, score: #{@submission.score} })"
  end

  # GET /submissions
  def index
    @submissions = Submission.list.page params[:page]
  end

  # GET /submissions/1
  def show
    @submission = Submission.find(params[:id])
  end

  # GET /submissions/new
  def new
    @submission = Submission.new params[:submission]
  end

  # GET /submissions/1/edit
  def edit
    assign_submission
  end

  def assign_submission
    if current_user.try :admin
      @submission = Submission.find(params[:id])
    else
      @submission = Submission.where(:user_id => current_user.id, :id => params[:id]).first
      raise "Could not find submission. Are you trying to edit someone else's?" if @submission.nil?
    end
  end

  # POST /submissions
  def create
    values = params[:submission].merge({:user => current_user})
    @submission = Submission.new(values)

    if Antispam.new.is_spam? @submission
      logger.warn "Submission was treated as spam"
      flash[:alert] = "Your submission was flagged as spam. Don't worry though. An administrator should allow your submission to be published soon."
      @submission.mark_as_spam
    else
      Antispam.new.train_as_content @submission
    end

    if @submission.save
      redirect_to(@submission, :notice => 'Your submission was received. Thanks.')
    else
      render :action => "new"
    end
  end

  # PUT /submissions/1
  # PUT /submissions/1.xml
  def update
    @submission = Submission.find(params[:id])

    if @submission.update_attributes(params[:submission])
      redirect_to(@submission, :notice => 'Submission was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /submissions/1
  # DELETE /submissions/1.xml
  def destroy
    @submission = Submission.find(params[:id])
    @submission.destroy

    redirect_to(submissions_url)
  end
end
