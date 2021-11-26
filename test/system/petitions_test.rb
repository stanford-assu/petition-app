require "application_system_test_case"

class PetitionsTest < ApplicationSystemTestCase
  setup do
    @petition = petitions(:one)
  end

  test "visiting the index" do
    visit petitions_url
    assert_selector "h1", text: "Petitions"
  end

  test "creating a Petition" do
    visit petitions_url
    click_on "New Petition"

    fill_in "Content", with: @petition.content
    fill_in "Slug", with: @petition.slug
    fill_in "Title", with: @petition.title
    click_on "Create Petition"

    assert_text "Petition was successfully created"
    click_on "Back"
  end

  test "updating a Petition" do
    visit petitions_url
    click_on "Edit", match: :first

    fill_in "Content", with: @petition.content
    fill_in "Slug", with: @petition.slug
    fill_in "Title", with: @petition.title
    click_on "Update Petition"

    assert_text "Petition was successfully updated"
    click_on "Back"
  end

  test "destroying a Petition" do
    visit petitions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Petition was successfully destroyed"
  end
end
