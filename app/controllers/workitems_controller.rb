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

#require 'openwfe/representations'


class WorkitemsController < ApplicationController

  before_filter :login_required

  # GET /workitems
  #  or
  # GET /workitems?wfid=:wfid
  #  or
  # GET /workitems?q=:q || GET /workitems?query=:query
  #
  def index

    @wfid = params[:wfid]
    @query = params[:q] || params[:query]

    @workitems = if @wfid
      OpenWFE::Extras::Workitem.find_all_by_wfid(@wfid)
    elsif @query
      OpenWFE::Extras::Workitem.search(@query)
    else
      OpenWFE::Extras::Workitem.find(:all)
    end

    respond_to do |format|
      format.html # => app/views/workitems/index.html.erb
      format.json { render :text => 'json' }
      format.xml { render :text => 'xml' }
    end
  end

  # GET /workitems/:id/edit
  #
  def edit
    render :text => 'not yet implemented'
  end

  # GET /workitems/:id
  #
  def show

    @workitem = OpenWFE::Extras::Workitem.find(params[:id])

    respond_to do |format|
      format.html # => app/views/show.html.erb
      format.json { render :text => 'json' }
      format.xml { render :text => 'xml' }
    end
  end

  # PUT /workitems/:id
  #
  def update
    render :text => 'not yet implemented'
  end

  protected

    def authorized? (action=action_name, resource=nil)

      return false unless current_user

      return true if [ 'show', 'index' ].include?(action)

      current_user.is_admin?
    end
end

