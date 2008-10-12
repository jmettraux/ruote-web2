
require File.dirname(__FILE__) + '/../test_helper'


class WfidUrlsTest < ActiveSupport::TestCase

  def test_exp_path

    exp = Struct.new(:wfid, :expid).new(
      '20081009-toto', '1.0')

    b = ActionView::Base.new
    b.request = Struct.new(:protocol, :host_with_port).new(
      'http://', 'example.com')

    assert_equal(
      "http://example.com/expressions", b.expressions_url())
    assert_equal(
      "http://example.com/expressions/#{exp.wfid}", b.expressions_url(exp.wfid))
    assert_equal(
      "http://example.com/expressions/#{exp.wfid}/1_0", b.expression_url(exp))
  end
end

