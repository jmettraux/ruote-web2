
require File.dirname(__FILE__) + '/../test_helper'


class ExpressionsControllerTest < ActionController::TestCase

  fixtures :users, :groups

  def setup
    @fei = RuotePlugin.ruote_engine.launch(OpenWFE.process_definition {
      sequence { alice; bob }
    })
    sleep 0.200
  end
  def teardown
    RuotePlugin.ruote_engine.cancel_process(@fei.wfid)
    sleep 0.200
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

    p @response.headers
  end

  def test_cancelling_root_expression_redirect_to_processes_index

    raise "implement me !"
  end
end
