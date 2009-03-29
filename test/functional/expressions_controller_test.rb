
require File.dirname(__FILE__) + '/../test_helper'


class ExpressionsControllerTest < ActionController::TestCase

  fixtures :users, :groups

  def setup
    @fei = RuotePlugin.ruote_engine.launch(OpenWFE.process_definition {
      sequence { alice; bob }
    })
    sleep 0.250
  end
  def teardown
    if @fei
      RuotePlugin.ruote_engine.cancel_process(@fei.wfid)
      sleep 0.250
    end
  end

  def test_admin_can_get_expression

    login_as :admin

    get :show, :wfid => @fei.wfid, :expid => '0_0'
    assert_response :success
  end

  def test_plain_user_cannot_get_expression

    login_as :aaron

    get :show, :wfid => @fei.wfid, :expid => '0_0'
    assert_response 302
  end

  # TODO
  #
  #def test_plain_user_cannot_get_expression_xml
  #  fei = launch_process
  #  login_as :admin
  #  get :show, :wfid => fei.wfid, :expid => '0_0'
  #  assert_response 403 / 404
  #end

  def test_admin_can_cancel_expression

    login_as :admin

    delete :destroy, :wfid => @fei.wfid, :expid => '0_0_0'
    assert_response 302

    #p @response.headers
    assert_equal(
      "http://test.host/processes/#{@fei.wfid}", @response.headers['Location'])

    ps = RuotePlugin.ruote_engine.process_status(@fei.wfid)
    wi = ps.applied_workitems.first
    assert_equal '0.0.1', wi.fei.expid
  end

  def test_cancelling_root_expression_redirect_to_processes_index

    login_as :admin

    delete :destroy, :wfid => @fei.wfid, :expid => '0'
    assert_response 302

    #p @response.headers
    assert_equal('http://test.host/processes', @response.headers['Location'])

    @fei = nil # prevents teardown from cancelling the now missing process
  end
end
