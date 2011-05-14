class UsersController < ApplicationController
  before_filter :require_admin!, :except => [:show, :show_comments, :show_submissions, :edit, :update, :best_of]

  def best_of
    @users = User.highest_karma_users.page params[:page]
  end

  def update_profile_text
    @user = current_user
  end

  def show
    @user = User.find params[:id]
  end
  alias :show_comments :show
  alias :show_submissions :show

  def spammers
    @users = User.find_spammers.page params[:page]
  end

  # GET /users
  # GET /users.xml
  def index
    @users = User.page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    params[:user].reject!{|key, _| key.to_sym != :profile_text } if !current_user_is_admin?
    raise "admins only" if current_user != @user and !current_user_is_admin?

    if @user.update_attributes(params[:user])
      @user.update_attribute :admin, true if params[:user][:admin] == "1" and current_user_is_admin?
      redirect_to(user_path(@user), :notice => 'Your changes were saved.')
    else
      render :action => "edit"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.mark_as_deleted
    @user.save!
    flash[:notice] = "User #{@user} was deleted."

    redirect_to(users_url)
  end
end
