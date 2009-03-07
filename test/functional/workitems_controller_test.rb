
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

  fixtures :users, :groups, :ar_workitems

  def setup
    super
    OpenWFE::Extras::HistoryEntry.destroy_all
  end

  def test_should_not_get_index
    get :index
    assert_response :redirect
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
  end

  def test_should_get_index_xml
    login_as :admin
    get :index, :format => 'xml'
    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  def test_should_get_empty_index
    #
    # aaron can't see any workitems (since there is only one in a weirdo
    # store)
    # (admin can see all the workitems)
    #
    login_as :aaron
    get :index, :format => 'json'
    assert_response :success
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], json['elements']
  end

  def test_should_get_index_json
    login_as :admin
    get :index, :format => 'json'
    assert_response :success
    assert_equal 'application/json', @response.content_type
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, json['elements'].size
  end

  def test_should_show_workitem
    login_as :admin
    get :show, :wfid => '20081003-gajoyususo', :expid => '0_0_1'
    assert_response :success
  end

  def test_should_not_show_workitem
    login_as :aaron
    get(
      :show,
      :wfid => '20081003-gajoyususo', :expid => '0_0_1', :format => 'xml')
    assert_response :not_found
      # well... at least prevents probes...
  end

  def test_should_show_xml
    login_as :admin
    get(
      :show,
      :wfid => '20081003-gajoyususo', :expid => '0_0_1', :format => 'xml')
    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  def test_should_save_workitem

    login_as :admin

    put(
      :update,
      { :wfid => '20081003-gajoyususo',
        :expid => '0_0_1',
        :fields => '{ "type": "petit bateau" }' })

    assert_response 302
    assert_equal 'http://test.host/workitems', @response.headers['Location']
    wi = OpenWFE::Extras::ArWorkitem.find(1).as_owfe_workitem
    assert_equal 'petit bateau', wi.attributes['type']

    hes = OpenWFE::Extras::HistoryEntry.find_all_by_wfid(wi.fei.wfid)
    #puts; hes.each { |he| p he }
    assert_equal 1, hes.size
    assert_equal 'saved', hes.first.event
    assert_equal 'admin', hes.first.source
  end

  def test_should_end_in_user_store

    fei = RuotePlugin.ruote_engine.launch(
      [ 'sequence', {}, [
        [ 'participant', { 'ref' => 'aaron' }, [] ] ] ])
    sleep 0.350

    assert_equal 'aaron', OpenWFE::Extras::ArWorkitem.find(:all).last.store_name

    RuotePlugin.ruote_engine.cancel_process(fei)
    sleep 0.350
  end

  def test_should_end_in_unknown_store

    fei = RuotePlugin.ruote_engine.launch(
      [ 'sequence', {}, [
        [ 'participant', { 'ref' => 'nemo' }, [] ] ] ])
    sleep 0.350

    assert_equal 'unknown', OpenWFE::Extras::ArWorkitem.find(:all).last.store_name

    RuotePlugin.ruote_engine.cancel_process(fei)
    sleep 0.350
  end

  def test_should_proceed_workitem

    fei = RuotePlugin.ruote_engine.launch(
      [ 'sequence', {}, [
        [ 'participant', { 'ref' => 'aaron' }, [] ],
        [ 'participant', { 'ref' => 'bob' }, [] ] ] ])
    sleep 0.350

    login_as :admin

    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success

    #puts @response.body
    #puts fei.wfid

    workitems = ActiveSupport::JSON.decode(@response.body)

    wi = workitems['elements'].find { |wi|
      wi['flow_expression_id']['workflow_instance_id'] == fei.wfid }

    assert_not_nil wi['links']

    assert_equal 'aaron', wi['participant_name']

    atts = wi['attributes']
    atts['girl'] = 'Ukifune'

    wfei = wi['flow_expression_id']

    put(
      :update,
      { :wfid => wfei['workflow_instance_id'],
        :expid => swapdots(wfei['expression_id']),
        'state' => 'proceeded',
        'fields' => atts })

    sleep 0.350

    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success

    workitems = ActiveSupport::JSON.decode(@response.body)

    #p workitems['elements']
    #p workitems['elements'].size

    wi = workitems['elements'].find { |wi|
      wi['flow_expression_id']['workflow_instance_id'] == fei.wfid }

    assert_not_nil wi
    assert_equal 'Ukifune', wi['attributes']['girl']

    hes = OpenWFE::Extras::HistoryEntry.find_all_by_wfid(fei.wfid)
    assert_equal 5, hes.size

    hes = hes.select { |he| he.event == 'proceeded' }
    assert_equal 1, hes.size
  end

  def test_should_delegate_workitem

    login_as :admin

    put(
      :update,
      { :wfid => '20081003-gajoyususo',
        :expid => '0_0_1',
        :store_name => 'el_cheapo' })

    assert_response 302
    assert_equal 'http://test.host/workitems', @response.headers['Location']
    wi = OpenWFE::Extras::ArWorkitem.find(1)
    assert_equal 'el_cheapo', wi.store_name

    hes = OpenWFE::Extras::HistoryEntry.find_all_by_wfid(wi.wfid)
    assert_equal 1, hes.size
    assert_equal 'delegated', hes.first.event
  end
end

