require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @spot = spots(:one)
    @rating = ratings(:one)
    sign_in users(:one)
  end

  test "should get new" do
    get new_spot_rating_url(@spot)
    assert_response :success
  end

  test "should create rating" do
    assert_difference("Rating.count") do
      post spot_ratings_url(@spot), params: { rating: { review_body: @rating.review_body, review_title: @rating.review_title, score: @rating.score, spot_id: @rating.spot_id, user_id: @rating.user_id } }
    end

    assert_redirected_to spot_url(@spot)
  end

  test "should get edit" do
    get edit_spot_rating_url(@spot, @rating)
    assert_response :success
  end

  test "should not get edit if not rating creator" do
    sign_in users(:two)
    get edit_spot_rating_url(@spot, @rating)
    assert_redirected_to spot_url(@spot)
  end

  test "should update rating" do
    patch spot_rating_url(@spot, @rating), params: { rating: { review_body: @rating.review_body, review_title: @rating.review_title, score: @rating.score, spot_id: @rating.spot_id, user_id: @rating.user_id } }
    assert_redirected_to spot_url(@spot)
  end

  test "should not update rating if not rating creator" do
    sign_in users(:two)
    patch spot_rating_url(@spot, @rating), params: { rating: { review_body: @rating.review_body, review_title: @rating.review_title, score: @rating.score, spot_id: @rating.spot_id, user_id: @rating.user_id } }
    assert_redirected_to spot_url(@spot)
  end

  test "should destroy rating" do
    assert_difference("Rating.count", -1) do
      delete spot_rating_url(@spot, @rating)
    end

    assert_redirected_to spot_url(@spot)
  end

  test "should not destroy rating if not rating creator" do
    sign_in users(:two)
    assert_no_difference("Rating.count") do
      delete spot_rating_url(@spot, @rating)
    end

    assert_redirected_to spot_url(@spot)
  end
end
