require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get new" do
    get new_user_session_url
    assert_response :success
  end

  test "should create new session" do
    post user_session_url, params: { user: { login: @user.email, password: "password" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal @user.id, session["warden.user.user.key"][0][0]
  end

  test "should be able to sign in with username" do
    post user_session_url, params: { user: { login: @user.username, password: "password" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal @user.id, session["warden.user.user.key"][0][0]
  end
end
