
require File.dirname(__FILE__) + '/../test_helper'
require 'errors_controller'

# Re-raise errors caught by the controller.
class ErrorsController; def rescue_action(e) raise e end; end


class ErrorsControllerTest < ActionController::TestCase

  fixtures :users, :groups, :process_errors

  #def test_whatever
  #  fei = RuotePlugin.ruote_engine.launch(
  #    [ 'sequence', {}, [
  #      [ 'error', {}, [ 'FAIL!' ] ],
  #      [ 'participant', { 'ref' => 'bob' }, [] ] ] ])
  #end

  def test_should_get_index_xml

    login_as :admin
    get :index, :format => 'xml'
    assert_response :success
    assert_equal 'application/xml', @response.content_type

    puts @response.body
  end
end
