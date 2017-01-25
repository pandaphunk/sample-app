require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

	def setup
		@user = users(:micheal) # create a user from the fixtures
		remember(@user) #use remember method to remember the user
	end

	test "current_user returns right user when session is nil" do
		assert_equal @user, current_user # verify that current_user is equal to given user
		assert is_logged_in?
	end

	test "current_user returns nils when remember digest is wrong" do
		@user.update_attribute(:remember_digest, User.digest(User.new_token))
		assert_nil current_user # confirms that the user is nil if the remember digest doesn't correspond to the remember token (asert_equal <expected>, <actual>)
	end 
end
