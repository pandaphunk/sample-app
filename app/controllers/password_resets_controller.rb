class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # checks for expired reset token

  def new
  end

  def create # create action
  	@user = User.find_by(email: params[:password_reset][:email].downcase)
  	if @user
  		@user.create_reset_digest
  		@user.send_password_reset_email
  		flash[:info] = "Email has been sent to you, with reset instructions"
  		redirect_to root_url
  	else
  		flash.now[:danger] = "Email address not found"
  		render new
  	end
  end

  def edit
  end

  def update # update action
    if params[:user][:password].empty?
      @user.errors.add(:password, "cant be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params # user_params action
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    #Confirms a valid user.
    def valid_user # valid_user action
      unless (@user && @user.activated? &&
              @user.authenitcated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    def check_expiration # check_expiration action
      if @user.password_reset_expired?
        flash[:danger] = "Password Reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
