require "test_helper"

class ApiIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @spot_one = spots(:one)
    @spot_two = spots(:two)
  end

  # ── GET /api/spots ──────────────────────────────────────────────────

  test "api_index returns JSON" do
    get "/api/spots"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "api_index returns all spots" do
    get "/api/spots"
    json = JSON.parse(response.body)
    assert_equal Spot.count, json.length
  end

  test "api_index includes average_rating for each spot" do
    get "/api/spots"
    json = JSON.parse(response.body)
    json.each do |spot_data|
      assert spot_data.key?("average_rating"),
             "Each spot should include average_rating"
    end
  end

  test "api_index average_rating values are correct" do
    get "/api/spots"
    json = JSON.parse(response.body)
    spot_one_data = json.find { |s| s["id"] == @spot_one.id }
    assert_equal @spot_one.average_rating, spot_one_data["average_rating"]
  end

  test "api_index includes spot attributes" do
    get "/api/spots"
    json = JSON.parse(response.body)
    first_spot = json.first
    %w[id name description spot_type latitude longitude web_link].each do |attr|
      assert first_spot.key?(attr), "Spot JSON should include #{attr}"
    end
  end

  test "api_index can filter by spot_type" do
    get "/api/spots", params: { spot_type: "campsite" }
    json = JSON.parse(response.body)
    json.each do |spot_data|
      assert_equal "campsite", spot_data["spot_type"]
    end
  end

  test "api_index with non-existent spot_type returns empty" do
    get "/api/spots", params: { spot_type: "nonexistent" }
    json = JSON.parse(response.body)
    assert_empty json
  end

  test "api_index is accessible without authentication" do
    # No sign_in call - request should still succeed
    get "/api/spots"
    assert_response :success
  end

  # ── GET /api/spots/:id ──────────────────────────────────────────────

  test "api_show returns JSON for a single spot" do
    get "/api/spots/#{@spot_one.id}"
    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "api_show returns the correct spot" do
    get "/api/spots/#{@spot_one.id}"
    json = JSON.parse(response.body)
    assert_equal @spot_one.id, json["id"]
    assert_equal @spot_one.name, json["name"]
  end

  test "api_show includes average_rating" do
    get "/api/spots/#{@spot_one.id}"
    json = JSON.parse(response.body)
    assert json.key?("average_rating")
    assert_equal @spot_one.average_rating, json["average_rating"]
  end

  test "api_show is accessible without authentication" do
    get "/api/spots/#{@spot_two.id}"
    assert_response :success
  end

  test "api_show returns 404 for nonexistent spot" do
    get "/api/spots/999999"
    assert_response :not_found
  end

  # ── API reflects data changes ───────────────────────────────────────

  test "api reflects newly created spot" do
    sign_in users(:one)
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
    sign_in users(:one)
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
end
