require "application_system_test_case"

class SpotsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @user = users(:one)
    @spot = spots(:one)
    login_as(@user, scope: :user)
  end

  teardown do
    Warden.test_reset!
  end

  test "visiting the index" do
    visit spots_url
    assert_selector "h1", text: /van\s+spots/i
  end

  test "should create spot" do
    visit spots_url
    click_on "Create Spot"

    fill_in "Spot Name", with: "Test Beach Spot"
    select "Free Spot", from: "Spot Type"
    fill_in "Description", with: "A great free spot by the beach"
    fill_in "spot_latitude", with: "51.605411"
    fill_in "spot_longitude", with: "-3.983570"
    click_on "Create Spot"

    assert_text(/test beach spot/i)
  end

  test "should update spot" do
    visit spot_url(@spot)
    click_on "Edit Spot"

    fill_in "Spot Name", with: "Updated Spot Name"
    click_on "Update Spot"

    assert_text(/updated spot name/i)
  end
end
