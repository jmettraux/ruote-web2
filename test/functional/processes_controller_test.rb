
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
    @request.env['HTTP_ACCEPT'] = 'application/xml'
    get :index
    assert_response :success
    assert_match(/href="http:\/\/test.host:80\/processes"/, @response.body)
    assert_match(/count="0"/, @response.body)
  end

  def test_empty_process_list_json
    set_basic_authentication 'admin:admin'
    @request.env['HTTP_ACCEPT'] = 'application/json'
    get :index
    assert_response :success
    assert_equal '[]', @response.body
  end

  def test_launch_process_form
    login_as :admin
    post :create, :pdef => '["sequence",{},[["participant",{"ref":"toto"},[]]]]'
    assert_response 302
    assert_match /processes/, @response.headers['Location']
  end

  def test_launch_process_xml
    xml = <<-EOS
      <process>
        <definition>["sequence",{},[["participant",{"ref":"toto"},[]]]]</definition>
      </process>
    EOS
    set_basic_authentication 'admin:admin'
    rpost :create, xml, :format => :xml
    assert_response 201
    assert_match /processes/, @response.headers['Location']
    assert_equal 'application/xml', @response.content_type
    assert_match /wfid/, @response.body
  end

  def test_launch_process_json
    json = '{"definition":["sequence",{},[["participant",{"ref":"toto"},[]]]]}'
    set_basic_authentication 'admin:admin'
    rpost :create, json, :format => :json
    assert_response 201
    assert_match /processes/, @response.headers['Location']
    assert_equal 'application/json', @response.content_type
    b = ActiveSupport::JSON.decode @response.body
    assert_not_nil b['wfid']
  end

  def test_launch_process_error
    set_basic_authentication 'admin:admin'
    rpost :create, '', :format => :json
    assert_response 400
    assert_equal 'text/plain', @response.content_type
  end
end

