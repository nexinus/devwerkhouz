# frozen_string_literal: true

require "application_system_test_case"

class PromptsFormUiTest < ApplicationSystemTestCase
  test "user can select category, tone, format and output length" do
    visit new_prompt_path

    # Category chip selection
    assert_selector "button.category-chip", text: "Marketing & Growth"
    find("button.category-chip", text: "Marketing & Growth").click
    assert_field "prompt[category]", with: "Marketing & Growth", visible: :hidden

    # Tone primary chip selection
    assert_selector "button.tone-chip", text: "Friendly"
    find("button.tone-chip", text: "Friendly").click
    assert_field "prompt[tone]", with: "Friendly", visible: :hidden

    # Format via 'More' menu (select a value not in primary to verify label)
    assert_selector "button#format-more-toggle"
    find("button#format-more-toggle").click
    assert_selector "button.format-more-item", text: "Headline"
    find("button.format-more-item", text: "Headline").click
    assert_field "prompt[format]", with: "Headline", visible: :hidden
    assert_selector "#format-selected-label", text: /Selected:\s+Headline/

    # Output length segmented control
    assert_selector "button.length-btn", text: "Long"
    find("button.length-btn", text: "Long").click
    assert_field "prompt[length]", with: "long", visible: :hidden
  end
end


