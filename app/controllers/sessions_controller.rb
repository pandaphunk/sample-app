class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase) # pulls saved user from DB via email
  	if user && user.authenticate(params[:session][:password]) #compares the provided pass with the hashed pass from params
  		if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user) #ternary operator
  		  redirect_back_or user # rails auto converts to user_url(user)
  	  else
  		message = "Account not activated"
      message += "Check your email for the activation link"
      flash[:warning] = message
      redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
