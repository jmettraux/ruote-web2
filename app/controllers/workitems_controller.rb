#--
# Copyright (c) 2008-2009, John Mettraux, jmettraux@gmail.com
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


require 'openwfe/representations'


class WorkitemsController < ApplicationController

  before_filter :login_required

  # GET /workitems
  #  or
  # GET /workitems?q=:q || GET /workitems?query=:q
  #  or
  # GET /workitems?p=:p || GET /workitems?participant=:p
  #
  def index

    @query = params[:q] || params[:query]

    @workitems = if @query

      OpenWFE::Extras::ArWorkitem.search(
        @query,
        current_user.is_admin? ? nil : current_user.store_names)

      # TODO : paginate that !

    else

      opts = { :order => 'dispatch_time DESC' }

      opts[:conditions] = { :store_name => current_user.store_names } \
        unless current_user.is_admin?

      OpenWFE::Extras::ArWorkitem.paginate_by_params(
        [
          # parameter_name[, column_name]
          'wfid',
          [ 'workflow', 'wf_name' ],
          [ 'store', 'store_name' ],
          [ 'participant', 'participant_name' ]
        ],
        params,
        opts)
    end

    # TODO : escape pagination for XML and JSON ??

    respond_to do |format|

      format.html
        # => app/views/workitems/index.html.erb

      format.json do
        render(:json => OpenWFE::Json.workitems_to_h(
          @workitems,
          :linkgen => linkgen).to_json)
      end

      format.xml do
        render(:xml => OpenWFE::Xml.workitems_to_xml(
          @workitems,
          :indent => 2, :linkgen => linkgen))
      end
    end
  end

  # GET /workitems/:wfid/:expid/edit
  #
  def edit

    @workitem = find_workitem
    @payload_partial = determine_payload_partial(@workitem)

    return error_reply('no workitem', 404) unless @workitem

    # only responds in HTML...
  end

  # GET /workitems/:wfid/:expid
  #
  def show

    @workitem = find_workitem
    @payload_partial = determine_payload_partial(@workitem)

    return error_reply('no workitem', 404) unless @workitem

    respond_to do |format|
      format.html # => app/views/show.html.erb
      format.json { render :json => OpenWFE::Json.workitem_to_h(
        @workitem, :linkgen => linkgen).to_json }
      format.xml { render :xml => OpenWFE::Xml.workitem_to_xml(
        @workitem, :indent => 2, :linkgen => linkgen) }
    end
  end

  # PUT /workitems/:wfid/:expid
  #
  def update

    wi = find_workitem

    return error_reply('no workitem', 404) unless wi

    owi = wi.to_owfe_workitem

    wi1 = parse_workitem

    wid = "#{owi.fei.wfid}/#{OpenWFE.to_uscores(owi.fei.expid)}"

    if store_name = params[:store_name]

      wi.store_name = store_name

      wi.save!

      flash[:notice] = "workitem #{wid} delegated to store '#{store_name}'"

      history_log(
        'delegated',
        :fei => owi.fei, :message => "wi delegated to '#{store_name}'")

    elsif params[:state] == 'proceeded'

      #wi.destroy
      OpenWFE::Extras::ArWorkitem.destroy(wi.id)

      owi.attributes = wi1.attributes
      RuotePlugin.ruote_engine.reply(owi)

      flash[:notice] = "workitem #{wid} proceeded"

      history_log('proceeded', :fei => owi.fei)

    else

      wi.replace_fields(wi1.attributes)

      flash[:notice] = "workitem #{wid} modified"

      history_log('saved', :fei => owi.fei, :message => 'wi saved')
    end

    redirect_to :action => 'index'
      #
      # TODO : no need for a redirection in case of xml/json...
  end

  protected

  def authorized?

    current_user || false
  end

  #
  # find workitem, says 'unauthorized' if the user is attempting to
  # see / update an off-limit workitem
  #
  def find_workitem

    workitem = OpenWFE::Extras::ArWorkitem.find_by_wfid_and_expid(
      params[:wfid], OpenWFE.to_dots(params[:expid]))

    current_user.may_see?(workitem) ? workitem : nil
  end

  #
  # parsing incoming workitems
  #
  def parse_workitem

    begin

      ct = request.content_type.to_s

      # TODO : deal with Atom[Pub]

      return OpenWFE::Xml::workitem_from_xml(request.body.read) \
        if ct.match(/xml$/)

      return OpenWFE::Json.workitem_from_json(request.body.read) \
        if ct.match(/json$/)

      #
      # then we have a form...

      #if definition_id = params[:definition_id]
      #  definition = Definition.find(definition_id)
      #  params[:definition_url] = definition.local_uri if definition
      #end
      #if attributes = params[:attributes]
      #  params[:attributes] = ActiveSupport::JSON::decode(attributes)
      #end

      wi = OpenWFE::WorkItem.from_h(params)

      wi.attributes = ActiveSupport::JSON.decode(wi.attributes) \
        if wi.attributes.is_a?(String)

      wi

    rescue Exception => e

      logger.warn("failed to parse workitem : #{e}")

      nil
    end
  end
end

