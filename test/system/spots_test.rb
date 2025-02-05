require "application_system_test_case"

class SpotsTest < ApplicationSystemTestCase
  setup do
    @spot = spots(:one)
  end

  test "visiting the index" do
    visit spots_url
    assert_selector "h1", text: "Spots"
  end

  test "should create spot" do
    visit spots_url
    click_on "New spot"

    fill_in "Description", with: @spot.description
    fill_in "Name", with: @spot.name
    fill_in "Spot type", with: @spot.spot_type
    fill_in "User", with: @spot.user_id
    fill_in "Web link", with: @spot.web_link
    click_on "Create Spot"

    assert_text "Spot was successfully created"
    click_on "Back"
  end

  test "should update Spot" do
    visit spot_url(@spot)
    click_on "Edit this spot", match: :first

    fill_in "Description", with: @spot.description
    fill_in "Name", with: @spot.name
    fill_in "Spot type", with: @spot.spot_type
    fill_in "User", with: @spot.user_id
    fill_in "Web link", with: @spot.web_link
    click_on "Update Spot"

    assert_text "Spot was successfully updated"
    click_on "Back"
  end

  test "should destroy Spot" do
    visit spot_url(@spot)
    click_on "Destroy this spot", match: :first

    assert_text "Spot was successfully destroyed"
  end
end
