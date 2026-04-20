require "test_helper"

class PagesIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user_one = users(:one)
    @spot_one = spots(:one)
  end

  # ── Landing Page ─────────────────────────────────────────────────────

  test "landing page is accessible without authentication" do
    get root_url
    assert_response :success
  end

  test "landing page loads recent spots" do
    get root_url
    assert_response :success
    spots = assigns(:spots)
    assert_not_nil spots
    assert spots.length <= 6, "Landing page should show at most 6 spots"
  end

  test "landing page loads recent ratings with titles" do
    get root_url
    assert_response :success
    ratings = assigns(:ratings)
    assert_not_nil ratings
    assert ratings.length <= 6, "Landing page should show at most 6 ratings"
    ratings.each do |rating|
      assert rating.review_title.present?,
             "Landing page ratings should have review titles"
    end
  end

  test "landing page spots are ordered by newest first" do
    get root_url
    spots = assigns(:spots)
    if spots.length > 1
      spots.each_cons(2) do |a, b|
        assert a.created_at >= b.created_at,
               "Spots should be ordered newest first"
      end
    end
  end

  # ── Map Page ─────────────────────────────────────────────────────────

  test "map page is accessible without authentication" do
    get "/map"
    assert_response :success
  end

  test "map page is accessible when authenticated" do
    sign_in @user_one
    get "/map"
    assert_response :success
  end

  # ── User Profile ─────────────────────────────────────────────────────

  test "user profile page requires authentication" do
    get "/users/#{@user_one.id}"
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can view a user profile" do
    sign_in @user_one
    get "/users/#{@user_one.id}"
    assert_response :success
  end

  test "user profile shows the correct user data" do
    sign_in @user_one
    get "/users/#{@user_one.id}"
    assert_response :success
    assert_equal @user_one, assigns(:user)
  end

  test "user profile shows spot count" do
    sign_in @user_one
    get "/users/#{@user_one.id}"
    expected_count = Spot.where(user_id: @user_one.id).size
    assert_equal expected_count, assigns(:spotcount)
  end

  test "user profile loads user spots" do
    sign_in @user_one
    get "/users/#{@user_one.id}"
    spots = assigns(:spots)
    spots.each do |spot|
      assert_equal @user_one.id, spot.user_id
    end
  end

  test "user profile loads user ratings" do
    sign_in @user_one
    get "/users/#{@user_one.id}"
    ratings = assigns(:ratings)
    ratings.each do |rating|
      assert_equal @user_one.id, rating.user_id
    end
  end

  # ── Health Check ─────────────────────────────────────────────────────

  test "health check endpoint returns success" do
    get "/up"
    assert_response :success
  end
end
