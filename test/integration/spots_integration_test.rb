require "test_helper"

class SpotsIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user_one = users(:one)
    @user_two = users(:two)
    @spot_one = spots(:one)   # owned by user_one, ratings: 2+5 = avg 3.5
    @spot_two = spots(:two)   # owned by user_two, ratings: 1+2 = avg 1.5
    @spot_three = spots(:three) # owned by user_one, no ratings = avg 0
  end

  # ── Viewing Spots (Index) ────────────────────────────────────────────

  test "unauthenticated user can view spots index" do
    get spots_url
    assert_response :success
  end

  test "authenticated user can view spots index" do
    sign_in @user_one
    get spots_url
    assert_response :success
  end

  test "spots index is sorted by average rating descending" do
    get spots_url
    spots = assigns(:spots)
    assert spots.first.average_rating >= spots.second.average_rating,
           "Spots should be sorted by average rating descending"
  end

  test "spots index can be filtered by spot_type" do
    sign_in @user_one
    get spots_url, params: { spot_type: "campsite" }
    assert_response :success
    spots = assigns(:spots)
    spots.each do |spot|
      assert_equal "campsite", spot.spot_type
    end
  end

  test "spots index with non-existent spot_type returns empty" do
    get spots_url, params: { spot_type: "nonexistent_type" }
    assert_response :success
    assert_empty assigns(:spots)
  end

  # ── Viewing Spots (Show) ─────────────────────────────────────────────

  test "unauthenticated user cannot view a spot (requires auth)" do
    get spot_url(@spot_one)
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can view a spot" do
    sign_in @user_one
    get spot_url(@spot_one)
    assert_response :success
  end

  test "viewing a spot shows its details" do
    sign_in @user_one
    get spot_url(@spot_one)
    assert_response :success
    assert_select "body" # page renders
  end

  test "viewing a nonexistent spot returns not found" do
    sign_in @user_one
    get spot_url(id: 999999)
    assert_response :not_found
  end

  # ── Creating Spots ───────────────────────────────────────────────────

  test "unauthenticated user cannot access new spot form" do
    get new_spot_url
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "unauthenticated user cannot create a spot" do
    assert_no_difference("Spot.count") do
      post spots_url, params: { spot: {
        name: "Test Spot", description: "A test",
        spot_type: "campsite", latitude: 51.5, longitude: -3.9
      } }
    end
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "authenticated user can create a valid spot" do
    sign_in @user_one
    assert_difference("Spot.count", 1) do
      post spots_url, params: { spot: {
        name: "New Beach Spot", description: "Great van parking by the beach",
        spot_type: "free_spot", latitude: 51.612152, longitude: -3.966312
      } }
    end
    new_spot = Spot.last
    assert_equal "New Beach Spot", new_spot.name
    assert_equal "free_spot", new_spot.spot_type
    assert_equal @user_one.id, new_spot.user_id
    assert_redirected_to spot_url(new_spot)
  end

  test "created spot is associated with the current user" do
    sign_in @user_one
    post spots_url, params: { spot: {
      name: "My Spot", description: "Mine",
      spot_type: "paid_spot", latitude: 50.0, longitude: -4.0
    } }
    assert_equal @user_one.id, Spot.last.user_id
  end

  test "creating a spot with invalid type does not persist" do
    sign_in @user_one
    assert_no_difference("Spot.count") do
      post spots_url, params: { spot: {
        name: "Bad Type", description: "Test",
        spot_type: "invalid_type", latitude: 51.0, longitude: -3.0
      } }
    end
  end

  test "creating a spot with missing required fields does not persist" do
    sign_in @user_one
    assert_no_difference("Spot.count") do
      post spots_url, params: { spot: {
        name: "", description: "",
        spot_type: "campsite", latitude: nil, longitude: nil
      } }
    end
  end

  test "new spot form pre-fills latitude and longitude from params" do
    sign_in @user_one
    get new_spot_url, params: { latitude: "51.5", longitude: "-3.9" }
    assert_response :success
    # The controller sets @spot.latitude and @spot.longitude from params
    spot = assigns(:spot)
    assert_equal 51.5, spot.latitude.to_f
    assert_equal(-3.9, spot.longitude.to_f)
  end

  # ── Editing Spots ────────────────────────────────────────────────────

  test "spot owner can access edit form" do
    sign_in @user_one
    get edit_spot_url(@spot_one)
    assert_response :success
  end

  test "non-owner cannot access edit form" do
    sign_in @user_two
    get edit_spot_url(@spot_one) # spot_one owned by user_one
    assert_response :redirect
  end

  test "spot owner can update their spot" do
    sign_in @user_one
    patch spot_url(@spot_one), params: { spot: {
      name: "Updated Name", description: @spot_one.description,
      spot_type: @spot_one.spot_type,
      latitude: @spot_one.latitude, longitude: @spot_one.longitude
    } }
    assert_redirected_to spot_url(@spot_one)
    @spot_one.reload
    assert_equal "Updated Name", @spot_one.name
  end

  test "non-owner cannot update a spot" do
    sign_in @user_two
    original_name = @spot_one.name
    patch spot_url(@spot_one), params: { spot: {
      name: "Hacked Name", description: @spot_one.description,
      spot_type: @spot_one.spot_type,
      latitude: @spot_one.latitude, longitude: @spot_one.longitude
    } }
    assert_response :redirect
    @spot_one.reload
    assert_equal original_name, @spot_one.name
  end

  # ── Deleting Spots ──────────────────────────────────────────────────

  test "spot owner can delete their spot" do
    sign_in @user_one
    assert_difference("Spot.count", -1) do
      delete spot_url(@spot_three) # use spot_three to avoid cascade issues
    end
    assert_redirected_to spots_url
  end

  test "non-owner cannot delete a spot" do
    sign_in @user_two
    assert_no_difference("Spot.count") do
      delete spot_url(@spot_one) # spot_one owned by user_one
    end
    assert_response :redirect
  end

  test "deleting a spot also deletes its ratings" do
    sign_in @user_one
    rating_count = @spot_one.ratings.count
    assert rating_count > 0, "spot_one should have ratings for this test"
    assert_difference("Rating.count", -rating_count) do
      delete spot_url(@spot_one)
    end
  end

  # ── Full Create-View Flow ────────────────────────────────────────────

  test "create a spot then view it on the index and show pages" do
    sign_in @user_one
    # Create
    post spots_url, params: { spot: {
      name: "Flow Test Spot", description: "Testing the full flow",
      spot_type: "surf_spot", latitude: 51.6, longitude: -4.0
    } }
    new_spot = Spot.last
    assert_equal "Flow Test Spot", new_spot.name

    # View on show page
    get spot_url(new_spot)
    assert_response :success

    # View on index page
    get spots_url
    assert_response :success
    spot_names = assigns(:spots).map(&:name)
    assert_includes spot_names, "Flow Test Spot"
  end
end
