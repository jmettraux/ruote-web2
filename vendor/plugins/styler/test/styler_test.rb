require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/styler'
require 'action_view/helpers/tag_helper'

class StylerTest < Test::Unit::TestCase

  include ActionView::Helpers::TagHelper
  include Styler
  
  def test_this_plugin
    true
  end

end
