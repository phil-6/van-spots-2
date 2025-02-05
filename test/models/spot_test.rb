require "test_helper"

class SpotTest < ActiveSupport::TestCase
  setup do
    @spot = spots(:one)
  end

  test "should be able to get user who created spot" do
    assert_equal @spot.user, users(:one)
  end

  test "should be able to get ratings for spot" do
    assert_equal 2, @spot.ratings.count
  end

  test "should be able to get average rating for spot" do
    assert_equal 3.5, @spot.average_rating
  end

  test "should be able to create a spot with valid data" do
    spot = Spot.new(name: "Test", user_id: users(:one).id,  description: "Test", spot_type: "free_spot",
                    latitude: 51.612152, longitude: -3.966312)
    assert spot.save
  end

  test "should not be able to create a spot with an invalid spot type" do
    spot = Spot.new(name: "Test", description: "Test", spot_type: "Invalid", latitude: 0, longitude: 0)
    assert_not spot.save
  end

  test "should not be able to create a spot without a latitude or longitude " do
    spot = Spot.new(name: "Test", description: "Test", spot_type: "free_spot")
    assert_not spot.save
  end
end
