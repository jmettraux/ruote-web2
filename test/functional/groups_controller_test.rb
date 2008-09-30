
require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase

  fixtures :users
  fixtures :user_groups, :groups

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_should_not_get_index
    get :index
    assert_response 302
  end

  def test_should_not_get_index_2
    login_as :aaron
    get :index
    assert_response :success
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_should_create_group
    assert_difference('Group.count') do
      login_as :admin
      post :create, :group => { }
    end

    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_show_group
    login_as :admin
    get :show, :id => groups(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => groups(:one).id
    assert_response :success
  end

  def test_should_update_group
    login_as :admin
    put :update, :id => groups(:one).id, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_destroy_group
    assert_difference('Group.count', -1) do
      login_as :admin
      delete :destroy, :id => groups(:one).id
    end

    assert_redirected_to groups_path
  end
end
