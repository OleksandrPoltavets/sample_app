class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy


  def show
  	@user = User.find(params[:id])
  end	

  def new
    unless signed_not_admin?
      @user = User.new
    else
      flash[:alert] = "Already signed in."
      redirect_to(root_path)
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create
    unless signed_not_admin?
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        render 'new'
      end
    else
      admin_user
    end
  end    

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end    
  end

  def destroy
    user = User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User \"#{user.name}\" removed."
    else
      flash[:error] = "Cannot delete own account!"
    end
    redirect_to users_url
  end

  private

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def signed_not_admin?
      signed_in? && !(current_user.admin?)
    end
end
