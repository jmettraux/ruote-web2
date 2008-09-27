
require File.dirname(__FILE__) + '/../test_helper'

class GroupDefinitionsControllerTest < ActionController::TestCase

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert_not_nil assigns(:group_definitions)
  end

  def test_should_create_group_definition
    login_as :admin
    assert_difference('GroupDefinition.count') do
      post :create, :group_definition => { }
    end
    assert_redirected_to group_definition_path(assigns(:group_definition))
  end

  def test_should_show_group_definition
    login_as :admin
    get :show, :id => group_definitions(:one).id
    assert_response :success
  end

  def test_should_destroy_group_definition
    login_as :admin
    assert_difference('GroupDefinition.count', -1) do
      delete :destroy, :id => group_definitions(:one).id
    end
    assert_redirected_to group_definitions_path
  end
end
