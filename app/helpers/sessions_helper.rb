module SessionsHelper
	# Logs in the given user
	def log_in(user)
		session[:user_id] = user.id
	end

	#Remembers a user in a persistent session.
	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	#returns true if the given user is the current user
	def current_user?(user)
		user == current_user
	end

	# returns the current logged in user
	def current_user
		if (user_id = session[:user_id]) # read: if session of user id exists (while setting user id to session of user id)...
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id]) # read like: If cookies signed user id exists while setting it to user_id
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	# returns true if the user is logged in
	def logged_in?
		!current_user.nil?
	end

	# Forgets a persistent session
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end

	# redirects to stored location (or to the default)
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

	# stores the URL trying to be accessed
	def store_location
		session[:forwarding_url] = request.original_url if request.get?
	end
end