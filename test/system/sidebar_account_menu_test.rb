# frozen_string_literal: true

require "application_system_test_case"

class SidebarAccountMenuTest < ApplicationSystemTestCase
  test "account menu toggles and closes on outside click" do
    visit dashboard_path

    # Open menu
    assert_selector "[data-account-menu-target='button']"
    find("[data-account-menu-target='button']").click
    assert_selector "[data-account-menu-target='menu']:not(.hidden)"

    # Click outside (anywhere on the page outside the controller element)
    find("body").click
    assert_selector "[data-account-menu-target='menu'].hidden"
  end
end


