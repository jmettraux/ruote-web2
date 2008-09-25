
require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase

  fixtures :users
  fixtures :user_groups, :groups

  def test_is_admin
    assert users(:admin).is_admin?
  end

  def test_is_not_admin
    assert (not users(:quentin).is_admin?)
  end
end

