
require File.dirname(__FILE__) + '/../test_helper'

class GroupDefinitionTest < ActiveSupport::TestCase

  fixtures :users
  fixtures :user_groups, :groups, :group_definitions, :definitions

  def test_admin_launch_rights
    u = users(:admin)
    assert u.may_launch?(:anything)
  end

  def test_quentin_launch_rights
    u = users(:quentin)
    assert u.may_launch?(definitions(:one))
    assert ! u.may_launch?(definitions(:two))
  end

  def test_aaron_launch_rights
    u = users(:aaron)
    assert ! u.may_launch?(definitions(:one))
    assert ! u.may_launch?(definitions(:two))
  end
end

