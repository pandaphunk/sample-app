class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email: params[:session][:email].downcase) # pulls saved user from DB via email
  	if user && user.authenticate(params[:session][:password]) #compares the provided pass with the hashed pass from params
  		log_in user
  		redirect_to user # rails auto converts to user_url(user)
  	else
  		flash.now[:danger] = "Invalid email or password confirmation" # flash.now dissapears as soon as there is another request
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

end
