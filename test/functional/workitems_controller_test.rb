
require File.dirname(__FILE__) + '/../test_helper'
require 'workitems_controller'

# Re-raise errors caught by the controller.
class WorkitemsController; def rescue_action(e) raise e end; end

class ActionController::TestRequest
  def path_info
    'path_info'
  end
end

class WorkitemsControllerTest < ActionController::TestCase

  fixtures :users, :groups
  #fixtures :workitems

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
    get :show, :wfid => '20081003-gajoyususo', :expid => '0.0.1'
    assert_response :success
  end

  def test_should_save_workitem
    login_as :admin
    put(
      :update,
      { :wfid => '20081003-gajoyususo',
        :expid => '0.0.1',
        :fields => '{ "type": "petit bateau" }' })
    assert_response 302
    assert_equal 'http://test.host/workitems', @response.headers['Location']
    wi = OpenWFE::Extras::Workitem.find(1).as_owfe_workitem
    assert_equal 'petit bateau', wi.attributes['type']
  end

  def test_should_proceed_workitem

    fei = RuotePlugin.ruote_engine.launch(
      [ 'sequence', {}, [
        [ 'participant', { 'ref' => 'alice' }, [] ],
        [ 'participant', { 'ref' => 'bob' }, [] ] ] ])
    sleep 0.350

    login_as :admin

    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success

    workitems = ActiveSupport::JSON.decode(@response.body)

    wi = workitems['elements'].find { |wi|
      wi['flow_expression_id']['workflow_instance_id'] == fei.wfid }

    assert_not_nil wi['links']

    assert_equal 'alice', wi['participant_name']

    atts = wi['attributes']
    atts['girl'] = 'Ukifune'

    wfei = wi['flow_expression_id']

    Thread.new do # preventing timeout... weird...
    put(
      :update,
      { :wfid => wfei['workflow_instance_id'], :expid => wfei['expression_id'],
        'state' => 'proceeded', 'fields' => atts })
    end

    sleep 0.350

    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success

    workitems = ActiveSupport::JSON.decode(@response.body)

    wi = workitems['elements'].find { |wi|
      wi['flow_expression_id']['workflow_instance_id'] == fei.wfid }

    assert_not_nil wi
  end
end

