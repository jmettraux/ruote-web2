
require File.dirname(__FILE__) + '/../test_helper'
require 'errors_controller'

# Re-raise errors caught by the controller.
class ErrorsController; def rescue_action(e) raise e end; end


class ErrorsControllerTest < ActionController::TestCase

  fixtures :users, :groups, :process_errors

  def test_should_get_index_xml

    login_as :admin
    get :index, :format => 'xml'
    assert_response :success
    assert_equal 'application/xml', @response.content_type

    #puts @response.body
    assert_match /errors count="1"/, @response.body
  end

  def test_should_get_index_json

    login_as :admin
    get :index, :format => 'json'
    assert_response :success
    assert_equal 'application/json', @response.content_type

    #puts @response.body
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal 1, json['elements'].size
    assert_equal 2, json['elements'].first['links'].size
  end

  #def test_whatever
  #  fei = RuotePlugin.ruote_engine.launch(
  #    [ 'sequence', {}, [
  #      [ 'error', {}, [ 'FAIL!' ] ],
  #      [ 'participant', { 'ref' => 'bob' }, [] ] ] ])
  #end

  def test_should_replay_error

    missing_participant = RuotePlugin.ruote_engine.register_participant(
      'missing', :position => :first
    ) do |workitem|
      raise "something went wrong"
    end

    fei = RuotePlugin.ruote_engine.launch(
      [ 'sequence', {}, [
        [ 'participant', { 'ref' => 'missing'}, [] ],
        [ 'participant', { 'ref' => 'bob' }, [] ] ] ])

    sleep 0.500

    login_as :admin

    get :index, :format => 'xml'
    #puts @response.body
    assert_match /errors count="2"/, @response.body
    assert_match /message>something went wrong<\/message/, @response.body

    #
    # fix ...

    RuotePlugin.ruote_engine.unregister_participant('missing')
    missing_participant = RuotePlugin.ruote_engine.register_participant(
      'missing', :position => :first
    ) do |workitem|
      # let pass...
    end

    #
    # and replay at error ...

    delete :destroy, :wfid => fei.wfid, :expid => '0_0_0'
    assert_equal "replayed /errors/#{fei.wfid}/0_0_0", flash[:notice]

    sleep 0.500

    get :index, :format => 'xml'
    #puts @response.body
    assert_match /errors count="1"/, @response.body

    assert_equal 1, RuotePlugin.ruote_engine.processes.size
    assert_equal 0, RuotePlugin.ruote_engine.processes.first.errors.size

    #
    # cleaning up

    RuotePlugin.ruote_engine.cancel_process(fei.wfid)

    sleep 0.500
  end
end

