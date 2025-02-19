require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should be able to get spots created by user" do
    assert_equal 2, @user.spots.count
  end

  test "should be able to get ratings created by user" do
    assert_equal 2, @user.ratings.count
  end

  test "should not be able to create a username with someone else's username" do
    user = User.new(username: "test-one", email: "test2@example.com", description: "test", password: "password")
    assert_not user.save
    assert_includes user.errors[:username], "has already been taken"
  end

  test "should not be able to create a username that is someone else's email" do
    user = User.new(username: "test@example.com", email: "test2@example.com", description: "test", password: "password")
    assert_not user.save
    assert_includes user.errors[:username], "only allows letters, numbers, underscores, and dots"
  end

  test "should be able to create a user with a unique username" do
    user = User.new(username: "test", email: "test2@example.com", description: "test", password: "password")
    assert user.save
  end
end
