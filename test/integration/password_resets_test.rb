require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
  	ActionMailer::Base.deliveries.clear
  	@user = users(:micheal)
  end

  def "password resets" do 
  	get new_password_reset_path
  	assert_template 'password_resets/new' # confirms the correct view is rendereed
  	#invalid email
  	post password_resets_path, params: { password_reset: { email: "" } }
  	assert_not flash.empty?
  	assert_template 'password_resets/new'
  	# Valid Email
  	post password_resets_path, params: { password_reset: { email: @user.email } }
  	assert_not_equal @user.reset_digest, @user.reload.reset_digest
  	assert_equal 1, ActionMailer::Base.deliveries.size
  	assert_not flash.empty?
  	assert_redirected_to root_url
  	# Password Reset Form
  	user = assigns(:user)
  	# Wrong email
  	get edit_password_reset_path(user.reset_token, email: "")
  	assert_redirtected_to root_url
  	#inactive user
  	user.toggle!(:activated)
  	# Right email, wrong token
  	get edit_password_reset_path('wrong token', email: user.email)
  	assert_redirected_to root_url
  	# Right email, right token
  	gt edit_password_reset_path(user.reset_token, email: user.email)
  	assert_template 'password_resets/edit'
  	assert_select "input[name=email][type=hidden][value=?]", user,email
  	#invalid password and confirmation
  	patch password_reset_path(user.reset_token), params: { email: user.email, 
  														   user: { password: "foobaz",
  														   		   password_confirmation: "barquux"} }
  	assert_select"div#error_explanation"
  	#empty password
  	patch password_reset_path(user.reset_token)
  		params: { email: user.email,
  				  user: { password: "",
  				  		  password_confirmation: "" } }
  	assert_select "div#error_explanation"
  	# Valid Password & confirmation
  	patch password_reset_path(user.reset_token)
  		params: { email: user.email,
  				  user: { password:              "foobaz"
  				  		  password_confirmation: "foobaz" } }
  	assert is_logged_in?
  	assert_not flash.empty?
  	assert_redirected_to user
  end
end
