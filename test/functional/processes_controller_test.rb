
require File.dirname(__FILE__) + '/../test_helper'
require 'processes_controller'

# Re-raise errors caught by the controller.
class ProcessesController; def rescue_action(e) raise e end; end

class ProcessesControllerTest < ActionController::TestCase

  fixtures :users

  def test_no_access
    get :index
    assert_response :redirect
  end

  def test_empty_process_list
    login_as :admin
    get :index
    assert_response :success
  end

  def test_empty_process_list_xml_no_access
    login_as :admin
    get :index, {}, { 'accept' => 'application/xml' }
    assert_response :redirect
  end

  def test_empty_process_list_xml
    set_basic_authentication "admin:admin"
    #get :index, {}, { 'accept' => 'application/xml' }
    @request.env['HTTP_ACCEPT'] = 'application/xml'
    get :index
    assert_response :success
    assert_match(/href="http:\/\/test.host:80\/processes"/, @response.body)
    assert_match(/count="0"/, @response.body)
  end

  def test_empty_process_list_json
    set_basic_authentication "admin:admin"
    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success
    assert_equal "[]", @response.body
  end
end
