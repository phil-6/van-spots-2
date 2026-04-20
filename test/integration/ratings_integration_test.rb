require "test_helper"

class RatingsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @spot_one = spots(:one)   # owned by user_one
    @spot_two = spots(:two)   # owned by user_two
    @spot_three = spots(:three) # owned by user_one, no ratings
    @rating_one = ratings(:one) # user_one on spot_one, score 2
    @rating_two = ratings(:two) # user_two on spot_one, score 5
  end

  # ── Unauthenticated Access ──────────────────────────────────────────

  test "unauthenticated user cannot access new rating form" do
    get new_spot_rating_url(@spot_one)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "unauthenticated user cannot create a rating" do
    assert_no_difference("Rating.count") do
      post spot_ratings_url(@spot_one), params: { rating: {
        score: 8, review_title: "Great!", review_body: "Loved it",
        spot_id: @spot_one.id
      } }
    end
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  # ── Creating Ratings ─────────────────────────────────────────────────

  test "authenticated user can rate a spot" do
    sign_in @user_one
    assert_difference("Rating.count", 1) do
      post spot_ratings_url(@spot_three), params: { rating: {
        score: 7, review_title: "Nice spot", review_body: "Good parking",
        spot_id: @spot_three.id
      } }
    end
    assert_redirected_to spot_url(@spot_three)

    new_rating = Rating.last
    assert_equal 7, new_rating.score
    assert_equal "Nice spot", new_rating.review_title
    assert_equal @user_one.id, new_rating.user_id
    assert_equal @spot_three.id, new_rating.spot_id
  end

  test "creating a rating updates the spot average_rating" do
    sign_in @user_one
    old_avg = @spot_three.average_rating
    assert_equal 0, old_avg, "spot_three should have no ratings initially"

    post spot_ratings_url(@spot_three), params: { rating: {
      score: 8, spot_id: @spot_three.id
    } }

    @spot_three.reload
    assert_equal 8.0, @spot_three.average_rating
  end

  test "creating a rating without score does not persist" do
    sign_in @user_one
    assert_no_difference("Rating.count") do
      post spot_ratings_url(@spot_three), params: { rating: {
        review_title: "No score", spot_id: @spot_three.id
      } }
    end
  end

  test "rating can be created with only a score (no review)" do
    sign_in @user_one
    assert_difference("Rating.count", 1) do
      post spot_ratings_url(@spot_three), params: { rating: {
        score: 5, spot_id: @spot_three.id
      } }
    end
    new_rating = Rating.last
    assert_equal 5, new_rating.score
    assert_nil new_rating.review_title
    assert_nil new_rating.review_body
  end

  # ── Editing Ratings ──────────────────────────────────────────────────

  test "rating creator can access edit form" do
    sign_in @user_one
    get edit_spot_rating_url(@spot_one, @rating_one)
    assert_response :success
  end

  test "non-creator cannot access edit form" do
    sign_in @user_two
    get edit_spot_rating_url(@spot_one, @rating_one) # rating_one belongs to user_one
    assert_redirected_to spot_url(@spot_one)
  end

  test "rating creator can update their rating" do
    sign_in @user_one
    patch spot_rating_url(@spot_one, @rating_one), params: { rating: {
      score: 9, review_title: "Updated title",
      review_body: "Updated body", spot_id: @spot_one.id
    } }
    assert_redirected_to spot_url(@spot_one)
    @rating_one.reload
    assert_equal 9, @rating_one.score
    assert_equal "Updated title", @rating_one.review_title
  end

  test "non-creator cannot update a rating" do
    sign_in @user_two
    original_score = @rating_one.score
    patch spot_rating_url(@spot_one, @rating_one), params: { rating: {
      score: 10, review_title: "Hacked", spot_id: @spot_one.id
    } }
    assert_redirected_to spot_url(@spot_one)
    @rating_one.reload
    assert_equal original_score, @rating_one.score
  end

  test "updating a rating changes the spot average_rating" do
    sign_in @user_one
    # spot_one has ratings: score 2 (rating_one) + score 5 (rating_two) = avg 3.5
    old_avg = @spot_one.average_rating
    assert_equal 3.5, old_avg

    patch spot_rating_url(@spot_one, @rating_one), params: { rating: {
      score: 8, spot_id: @spot_one.id
    } }

    @spot_one.reload
    # Now: score 8 + score 5 = avg 6.5
    assert_equal 6.5, @spot_one.average_rating
  end

  # ── Deleting Ratings ─────────────────────────────────────────────────

  test "rating creator can delete their rating" do
    sign_in @user_one
    assert_difference("Rating.count", -1) do
      delete spot_rating_url(@spot_one, @rating_one)
    end
    assert_redirected_to spot_url(@spot_one)
  end

  test "non-creator cannot delete a rating" do
    sign_in @user_two
    assert_no_difference("Rating.count") do
      delete spot_rating_url(@spot_one, @rating_one) # rating_one belongs to user_one
    end
    assert_redirected_to spot_url(@spot_one)
  end

  test "deleting a rating updates the spot average_rating" do
    sign_in @user_one
    # spot_one has ratings: score 2 (rating_one) + score 5 (rating_two) = avg 3.5
    assert_equal 3.5, @spot_one.average_rating

    delete spot_rating_url(@spot_one, @rating_one)
    @spot_one.reload
    # Now only rating_two remains: score 5 = avg 5.0
    assert_equal 5.0, @spot_one.average_rating
  end

  # ── Full Create-View-Update-Delete Flow ──────────────────────────────

  test "full rating lifecycle: create, verify, update, delete" do
    sign_in @user_one

    # 1. Create a rating on spot_three (which has no ratings)
    assert_equal 0, @spot_three.average_rating

    post spot_ratings_url(@spot_three), params: { rating: {
      score: 7, review_title: "First review",
      review_body: "This is my review", spot_id: @spot_three.id
    } }
    new_rating = Rating.last
    @spot_three.reload
    assert_equal 7.0, @spot_three.average_rating

    # 2. View the spot to verify the rating appears
    get spot_url(@spot_three)
    assert_response :success

    # 3. Update the rating
    patch spot_rating_url(@spot_three, new_rating), params: { rating: {
      score: 9, review_title: "Updated review", spot_id: @spot_three.id
    } }
    @spot_three.reload
    assert_equal 9.0, @spot_three.average_rating

    # 4. Delete the rating
    delete spot_rating_url(@spot_three, new_rating)
    @spot_three.reload
    assert_equal 0, @spot_three.average_rating
  end
end
