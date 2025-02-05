require "test_helper"

class SpotsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @spot = spots(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get spots_url
    assert_response :success
  end

  test "index should be sorted by average rating" do
    get spots_url
    assert_equal spots(:one).average_rating, assigns(:spots).first.average_rating
    assert assigns(:spots).first.average_rating > assigns(:spots).second.average_rating
  end

  test "should get new" do
    get new_spot_url
    assert_response :success
  end

  test "should create spot" do
    assert_difference("Spot.count") do
      post spots_url, params: { spot: {
        description: @spot.description, name: @spot.name,
        spot_type: @spot.spot_type, web_link: @spot.web_link,
        latitude: 51.612152, longitude: -3.966312 } }
    end
    assert_redirected_to spot_url(Spot.last)
  end

  test "should show spot" do
    get spot_url(@spot)
    assert_response :success
  end

  test "should get edit" do
    get edit_spot_url(@spot)
    assert_response :success
  end

  test "should update spot" do
    patch spot_url(@spot), params: { spot: {
      description: @spot.description, name: @spot.name,
      spot_type: @spot.spot_type, web_link: @spot.web_link,
      latitude: 51.612152, longitude: -3.966312 } }
    assert_redirected_to spot_url(@spot)
  end

  test "should destroy spot" do
    assert_difference("Spot.count", -1) do
      delete spot_url(@spot)
    end

    assert_redirected_to spots_url
  end
end
