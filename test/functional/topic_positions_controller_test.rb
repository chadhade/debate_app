require 'test_helper'

class TopicPositionsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

  test "should get matches" do
    get :matches
    assert_response :success
  end

end
