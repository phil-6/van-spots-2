require "application_system_test_case"

class RatingsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    @user = users(:one)
    @spot = spots(:one)
    login_as(@user, scope: :user)
  end

  teardown do
    Warden.test_reset!
  end

  test "should create rating" do
    visit spot_url(@spot)
    click_on "Rate Spot"

    # Wait for the rating form to load
    assert_selector "h2", text: /how would you rate/i

    # The bar-rating Stimulus controller hides the native <select>,
    # so set the value directly via JavaScript.
    page.execute_script("document.querySelector('select[name=\"rating[score]\"]').value = '8'")
    fill_in "Review title", with: "Great spot!"
    fill_in "Review body", with: "Lovely views and quiet area"
    click_on "Rate Spot"

    # Redirects back to the spot show page
    assert_text(/#{Regexp.escape(@spot.name)}/i)
  end
end
