
require File.dirname(__FILE__) + '/../test_helper'


class WfidUrlsTest < ActiveSupport::TestCase

  def test_workitem_path

    wi = Struct.new(:wfid, :expid).new(
      '20081009-toto', '1.0')

    b = ActionView::Base.new
    b.request = Struct.new(:protocol, :host_with_port).new(
      'http://', 'example.com')

    assert_equal(
      "http://example.com/workitems", b.workitems_url())
    assert_equal(
      "http://example.com/workitems/#{wi.wfid}", b.workitems_url(wi.wfid))
    assert_equal(
      "http://example.com/workitems/#{wi.wfid}/1_0", b.workitem_url(wi))
  end
end

