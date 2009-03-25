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
# Made in Japan as opposed to "Swiss Made".
#++


#
# ruote-web2 uses db_error_journal, so tapping directly into the db is OK
#
class ErrorsController < ApplicationController

  before_filter :login_required

  # GET /errors
  #
  def index

    opts = { :page => params[:page], :order => 'created_at DESC' }

    @all = (opts[:conditions] == nil)
    @errors = OpenWFE::Extras::ProcessError.paginate(opts)

    respond_to do |format|

      format.html # => app/views/errors/index.html.erb

      format.xml do
        render(
          :xml => OpenWFE::Xml.errors_to_xml(
            @errors,
            :linkgen => LinkGenerator.new(request), :indent => 2))
      end

      format.json do
        render(:json => OpenWFE::Json.errors_to_h(
          @errors,
          :linkgen => LinkGenerator.new(request)).to_json)
      end
    end
  end

  # DELETE /errors/:wfid/:expid
  #
  def destroy

    e = OpenWFE::Extras::ProcessError.find_by_wfid_and_expid(
      params[:wfid], swapdots(params[:expid]))

    return error_reply(
      "no error at /errors/#{params[:wfid]}/#{params[:expid]}", 404
    ) unless e

    RuotePlugin.ruote_engine.replay_at_error(e)

    msg = "replayed /errors/#{params[:wfid]}/#{params[:expid]}"

    respond_to do |format|

      format.html do
        flash[:notice] = msg
        redirect_to :action => 'index'
      end
      format.xml do
        render :text => msg
      end
      format.json do
        render :text => msg
      end
    end
  end

  protected

  def authorized?

    return false unless current_user

    %w{ index }.include?(action_name) || current_user.is_admin?
  end
end

