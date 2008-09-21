#
#--
# Copyright (c) 2008, John Mettraux, OpenWFE.org
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# . Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#++
#

require 'openwfe/representations'


class ProcessesController < ApplicationController

  before_filter :login_required

  #
  # GET /processes
  #
  def index

    @processes = ruote_engine.list_process_status

    respond_to do |format|

      format.html # => app/views/processes.html.erb

      format.json do
        render :json => @processes.values.to_json
      end

      format.xml do
        render(
          :xml => OpenWFE::Xml::processes_to_xml(
            @processes, :request => request, :indent => 2))
      end
    end
  end

  def show
  end

  #
  # POST /processes
  #
  def create

    li = parse_launchitem

    # TODO : complain if no launchitem

    fei = ruote_engine.launch(li)

    flash[:notice] = "launched process instance #{fei.wfid}"

    # TODO
    #
    # html : redirect to a 'home' page
    # json and xml : no redirection but 201 and 'Location' header

    #headers['Location'] = "/processes/#{fei.wfid}"
    headers['Location'] = process_url(fei.wfid)

    respond_to do |format|

      format.html { redirect_to "/processes/#{fei.wfid}" }
      format.json { render :json => "{\"wfid\":#{fei.wfid}}", :status => 201 }
      format.xml { render :xml => "<wfid>#{fei.wfid}</wfid>", :status => 201 }
    end
  end

  protected

    def parse_launchitem

      ct = request.content_type.to_s

      return OpenWFE::Xml::launchitem_from_xml(request.body.read) \
        if ct == 'application/xml'

      h = params
      h = ActiveSupport::JSON.decode(request.body.read) \
        if ct == 'application/json'

      pdef_url = h['pdef_url'] || h['workflow_definition_url'] || h['definition_url']
      pdef = h['pdef'] || h['definition']

      fields = h['fields'] || {}
      fields = ActiveSupport::JSON.decode(h['fields']) if fields.is_a?(String)

      li = nil
      if pdef
        li = OpenWFE::LaunchItem.new(pdef)
      elsif url
        li = OpenWFE::LaunchItem.new
        li.definition_url = url
      end

      return nil unless li

      li.attributes.merge!(fields)

      li
    end
end

