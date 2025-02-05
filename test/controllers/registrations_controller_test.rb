require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_user_registration_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post user_registration_path, params: {
        user: {
          email: "test@email.com",
          username: "testregistration",
          description: "test description",
          password: "password",
          password_confirmation: "password" }
      }
    end
    assert_redirected_to root_path
    assert_equal "Welcome! You have signed up successfully.", flash[:notice]
    assert_emails 1
  end
end
