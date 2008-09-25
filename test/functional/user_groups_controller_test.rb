
require File.dirname(__FILE__) + '/../test_helper'

class UserGroupsControllerTest < ActionController::TestCase

  fixtures :user_groups, :groups

  def test_should_get_index
    login_as :admin
    get :index
    assert_redirected_to groups_path
  end

  def test_should_not_get_index
    get :index
    assert_response 302
  end

  def test_should_create_user_group
    login_as :admin
    assert_difference('UserGroup.count') do
      post :create, :user_group => { :group_id => 1, :user_id => 3 }
    end
    assert_redirected_to group_path(assigns(:user_group).group_id)
  end

  def test_should_show_user_group
    login_as :admin
    get :show, :id => user_groups(:two).id
    assert_redirected_to group_path(assigns(:user_group).group_id)
  end

  def test_should_update_user_group
    login_as :admin
    put :update, :id => user_groups(:two).id, :user_group => { :group_id => 1 }
    assert_redirected_to group_path(assigns(:user_group).group_id)
  end

  def test_should_destroy_user_group
    login_as :admin
    assert_difference('UserGroup.count', -1) do
      delete :destroy, :id => user_groups(:two).id
    end
    assert_redirected_to user_groups_path
  end
end
