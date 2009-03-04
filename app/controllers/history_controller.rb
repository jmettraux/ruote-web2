#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


class HistoryController < ApplicationController

  before_filter :login_required

  # GET /history
  #
  def index

    opts = { :page => params[:page], :order => 'created_at DESC' }

    cs = [
      :source, :wfid, :event, :participant, :wfname
    ].inject([[]]) do |a, p|
      if v = params[p]
        a.first << "#{p} = ?"
        a << v
      end
      a
    end

    opts[:conditions] = [ cs.first.join(' AND ') ] + cs[1..-1] \
      unless cs.first.empty?

    @all = (opts[:conditions] == nil)
    @entries = OpenWFE::Extras::HistoryEntry.paginate(opts)

    # TODO : XML and JSON
  end

  protected

  def authorized?

    (current_user != nil) # do I really need that ?...
  end
end

