require 'test_helper'

class ViewingsControllerTest < ActionController::TestCase
  test "should get leaving_page" do
    get :leaving_page
    assert_response :success
  end

end
