
require File.dirname(__FILE__) + '/../test_helper'

class DefinitionsControllerTest < ActionController::TestCase

  fixtures :users, :definitions

  def setup
    File.open('public/defs/ft_flow1.xml', 'w') {
      |f| f.puts('<process-definition name="flow1"></process-definition>')
    }
    File.open('public/defs/ft_flow2.rb', 'w') {
      |f| f.puts('OpenWFE.process_definition(:name => "flow2") {}')
    }
    File.open('public/defs/ft_toto.xml', 'w') {
      |f| f.puts('<process-definition name="toto"></process-definition>')
    }
  end
  def teardown
    Dir['public/defs/ft_*'].each { |f| FileUtils.rm(f) rescue nil }
  end

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert_not_nil assigns(:definitions)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end

  def test_should_create_definition
    login_as :admin
    assert_difference('Definition.count') do
      post :create, :definition => { :name => 't1', :uri => 'ft_toto.xml' }
    end
    assert_redirected_to definition_path(assigns(:definition))
  end

  def test_should_show_definition
    login_as :admin
    get :show, :id => definitions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => definitions(:one).id
    assert_response :success
  end

  def test_should_update_definition
    login_as :admin
    put :update, :id => definitions(:one).id, :definition => { :name => 'def1b', :uri => 'ft_flow1.xml' }
    assert_redirected_to definitions_path
  end

  def test_should_destroy_definition
    login_as :admin
    assert_difference('Definition.count', -1) do
      delete :destroy, :id => definitions(:one).id
    end
    assert_redirected_to definitions_path
  end
end
