require "test_helper"

class RatingTest < ActiveSupport::TestCase
  setup do
    @rating = ratings(:one)
  end

  test "should be able to get user who created rating" do
    assert_equal @rating.user, users(:one)
  end

  test "should be able to get spot for rating" do
    assert_equal @rating.spot, spots(:one)
  end

  test "should not be able to create with out a spot and a user" do
    rating = Rating.new(score: 3, review_title: "test", review_body: "test")
    assert_not rating.save
  end

  test "should not be able to create with out a score" do
    rating = Rating.new(user: users(:one), spot: spots(:one), review_title: "test", review_body: "test")
    assert_not rating.save
  end

  test "should be able to create a rating with all values" do
    rating = Rating.new(user: users(:one), spot: spots(:one), score: 3, review_title: "test", review_body: "test")
    assert rating.save
  end

  test "should be able to create a rating without a review title" do
    rating = Rating.new(user: users(:one), spot: spots(:one), score: 3, review_body: "test")
    assert rating.save
  end
end
