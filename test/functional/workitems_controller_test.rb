
require File.dirname(__FILE__) + '/../test_helper'
require 'workitems_controller'

# Re-raise errors caught by the controller.
class WorkitemsController; def rescue_action(e) raise e end; end

class WorkitemsControllerTest < ActionController::TestCase

  fixtures :users, :groups
  fixtures :workitems

  def test_should_not_get_index
    get :index
    assert_response :redirect
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
  end

  def test_should_show_workitem
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_workitem

    RuotePlugin.ruote_engine.launch([ 'participant', { 'ref' => 'toto' }, [] ])
    sleep 0.350

    login_as :admin
    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success

    p @response.body
  end
end

