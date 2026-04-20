require "test_helper"

class ApiIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @spot_one = spots(:one)
    @spot_two = spots(:two)
    @user = users(:one)
    @admin = users(:admin)
  end

  # ── Same-origin access (signed-in user) ─────────────────────────────

  test "api_index returns JSON for signed-in user" do
    sign_in @user
    get "/api/spots"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "api_index returns all spots for signed-in user" do
    sign_in @user
    get "/api/spots"
    json = JSON.parse(response.body)
    assert_equal Spot.count, json.length
  end

  test "api_index includes average_rating for each spot" do
    sign_in @user
    get "/api/spots"
    json = JSON.parse(response.body)
    json.each do |spot_data|
      assert spot_data.key?("average_rating"),
             "Each spot should include average_rating"
    end
  end

  test "api_index average_rating values are correct" do
    sign_in @user
    get "/api/spots"
    json = JSON.parse(response.body)
    spot_one_data = json.find { |s| s["id"] == @spot_one.id }
    assert_equal @spot_one.average_rating, spot_one_data["average_rating"]
  end

  test "api_index includes spot attributes" do
    sign_in @user
    get "/api/spots"
    json = JSON.parse(response.body)
    first_spot = json.first
    %w[id name description spot_type latitude longitude web_link].each do |attr|
      assert first_spot.key?(attr), "Spot JSON should include #{attr}"
    end
  end

  test "api_index can filter by spot_type" do
    sign_in @user
    get "/api/spots", params: { spot_type: "campsite" }
    json = JSON.parse(response.body)
    json.each do |spot_data|
      assert_equal "campsite", spot_data["spot_type"]
    end
  end

  test "api_index with non-existent spot_type returns empty" do
    sign_in @user
    get "/api/spots", params: { spot_type: "nonexistent" }
    json = JSON.parse(response.body)
    assert_empty json
  end

  # ── GET /api/spots/:id (same-origin) ────────────────────────────────

  test "api_show returns JSON for a single spot" do
    sign_in @user
    get "/api/spots/#{@spot_one.id}"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "api_show returns the correct spot" do
    sign_in @user
    get "/api/spots/#{@spot_one.id}"
    json = JSON.parse(response.body)
    assert_equal @spot_one.id, json["id"]
    assert_equal @spot_one.name, json["name"]
  end

  test "api_show includes average_rating" do
    sign_in @user
    get "/api/spots/#{@spot_one.id}"
    json = JSON.parse(response.body)
    assert json.key?("average_rating")
    assert_equal @spot_one.average_rating, json["average_rating"]
  end

  test "api_show returns 404 for nonexistent spot" do
    sign_in @user
    get "/api/spots/999999"
    assert_response :not_found
  end

  # ── API reflects data changes ───────────────────────────────────────

  test "api reflects newly created spot" do
    sign_in @user
    post spots_url, params: { spot: {
      name: "API Test Spot", description: "Testing API",
      spot_type: "free_spot", latitude: 51.5, longitude: -3.9
    } }
    new_spot = Spot.last

    get "/api/spots"
    json = JSON.parse(response.body)
    spot_ids = json.map { |s| s["id"] }
    assert_includes spot_ids, new_spot.id
  end

  test "api reflects updated average_rating after new rating" do
    sign_in @user
    old_avg = @spot_one.average_rating

    post spot_ratings_url(@spot_one), params: { rating: {
      score: 10, spot_id: @spot_one.id
    } }

    get "/api/spots/#{@spot_one.id}"
    json = JSON.parse(response.body)
    assert_not_equal old_avg, json["average_rating"]
    @spot_one.reload
    assert_equal @spot_one.average_rating, json["average_rating"]
  end

  # ── Bearer token access ─────────────────────────────────────────────

  test "api_index accessible with valid Bearer token" do
    token = @user.generate_api_token!
    get "/api/spots", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal Spot.count, json.length
  end

  test "api_show accessible with valid Bearer token" do
    token = @user.generate_api_token!
    get "/api/spots/#{@spot_one.id}", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @spot_one.id, json["id"]
  end

  test "api rejects invalid Bearer token" do
    get "/api/spots", headers: { "Authorization" => "Bearer invalidtoken123" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Invalid API token", json["error"]
  end

  test "api rejects malformed Authorization header" do
    get "/api/spots", headers: { "Authorization" => "Basic abc123" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert json["error"].include?("Invalid Authorization header format")
  end

  test "api rejects requests without auth or same-origin indicators" do
    get "/api/spots"
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "API token required. Use Authorization: Bearer <token>", json["error"]
  end

  test "regenerated token invalidates old token" do
    old_token = @user.generate_api_token!
    new_token = @user.generate_api_token!

    get "/api/spots", headers: { "Authorization" => "Bearer #{old_token}" }
    assert_response :unauthorized

    get "/api/spots", headers: { "Authorization" => "Bearer #{new_token}" }
    assert_response :success
  end

  test "revoked token returns unauthorized" do
    token = @user.generate_api_token!
    @user.revoke_api_token!

    get "/api/spots", headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized
  end

  # ── Admin token management ──────────────────────────────────────────

  test "admin can generate token for a user" do
    sign_in @admin
    post generate_api_token_admin_user_path(@user)
    assert_redirected_to "/users/#{@user.id}"
    @user.reload
    assert @user.has_api_token?
  end

  test "admin can revoke token for a user" do
    sign_in @admin
    @user.generate_api_token!
    delete revoke_api_token_admin_user_path(@user)
    assert_redirected_to "/users/#{@user.id}"
    @user.reload
    assert_not @user.has_api_token?
  end

  test "non-admin cannot generate token" do
    sign_in @user
    post generate_api_token_admin_user_path(users(:two))
    assert_redirected_to root_path
  end

  test "non-admin cannot revoke token" do
    sign_in @user
    delete revoke_api_token_admin_user_path(users(:two))
    assert_redirected_to root_path
  end
end
