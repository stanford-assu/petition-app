require "test_helper"

class PetitionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @petition = petitions(:one)
  end

  test "should get index" do
    get petitions_url
    assert_response :success
  end

  test "should get new" do
    get new_petition_url
    assert_response :success
  end

  test "should create petition" do
    assert_difference('Petition.count') do
      post petitions_url, params: { petition: { content: @petition.content, slug: @petition.slug, title: @petition.title } }
    end

    assert_redirected_to petition_url(Petition.last)
  end

  test "should show petition" do
    get petition_url(@petition)
    assert_response :success
  end

  test "should get edit" do
    get edit_petition_url(@petition)
    assert_response :success
  end

  test "should update petition" do
    patch petition_url(@petition), params: { petition: { content: @petition.content, slug: @petition.slug, title: @petition.title } }
    assert_redirected_to petition_url(@petition)
  end

  test "should destroy petition" do
    assert_difference('Petition.count', -1) do
      delete petition_url(@petition)
    end

    assert_redirected_to petitions_url
  end
end
