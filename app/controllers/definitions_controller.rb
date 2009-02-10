#
#--
# Copyright (c) 2008-2009, John Mettraux, OpenWFE.org
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

class DefinitionsController < ApplicationController

  before_filter :login_required

  # GET /definitions
  # GET /definitions.xml
  #
  def index

    @definitions = Definition.find_all_for(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @definitions.to_xml(:request => request) }
      format.json { render :json => @definitions.to_json(:request => request) }
    end
  end

  # GET /definitions/1
  # GET /definitions/1.xml
  #
  def show

    @definition = Definition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @definition.to_xml(:request => request) }
      format.json { render :json => @definition.to_json(:request => request) }
    end
  end

  # GET /definitions/:id/tree
  # GET /definitions/:id/tree.js
  #
  def tree

    @definition = Definition.find(params[:id])

    uri = @definition.local_uri

    # TODO : reject outside definitions ?

    pdef = (open(uri).read rescue nil)

    var = params[:var] || 'proc_tree'

    # TODO : use Rails callback thing (:callback)

    tree = pdef ?
      RuotePlugin.ruote_engine.get_def_parser.parse(pdef) :
      nil

    render(
      :text => "var #{var} = #{tree.to_json};",
      :content_type => 'text/javascript')
  end

  # GET /definitions/new
  # GET /definitions/new.xml
  #
  def new

    @definition = Definition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @definition.to_xml(:request => request) }
      format.json { render :json => @definition.to_json(:request => request) }
    end
  end

  # GET /definitions/1/edit
  #
  def edit

    @definition = Definition.find(params[:id])

    @dg_locals = {
      :in_groups => @definition.group_definitions,
      :out_groups => Group.find(:all) - @definition.groups
    }

    @payload_partial = determine_payload_partial(@definition)
  end

  # POST /definitions
  # POST /definitions.xml
  #
  def create

    @definition = Definition.new(params[:definition])

    respond_to do |format|

      if @definition.save

        flash[:notice] = 'Definition was successfully created.'

        format.html {
          redirect_to(@definition)
        }
        format.xml {
          render(
            :xml => @definition.to_xml(:request => request),
            :status => :created,
            :location => @definition)
        }
        format.json {
          render(
            :json => @definition.to_json(:request => request),
            :status => :created,
            :location => @definition)
        }

      else

        format.html {
          render(:action => 'new')
        }
        format.xml {
          render(:xml => @definition.errors, :status => :unprocessable_entity)
        }
        format.json {
          render(:json => @definition.errors, :status => :unprocessable_entity)
        }
      end
    end
  end

  # PUT /definitions/1
  # PUT /definitions/1.xml
  #
  def update

    @definition = Definition.find(params[:id])

    respond_to do |format|

      if @definition.update_attributes(params[:definition])

        flash[:notice] = 'Definition was successfully updated.'
        format.html { redirect_to :action => 'index' }
        format.xml { head :ok }
        format.json { head :ok }

      else # there is an error

        p @definition.errors

        format.html {
          render(:action => 'edit')
        }
        format.xml {
          render(:xml => @definition.errors, :status => :unprocessable_entity)
        }
        format.json {
          render(:json => @definition.errors, :status => :unprocessable_entity)
        }
      end
    end
  end

  # DELETE /definitions/1
  # DELETE /definitions/1.xml
  #
  def destroy

    @definition = Definition.find(params[:id])
    @definition.destroy

    respond_to do |format|
      format.html { redirect_to(definitions_url) }
      format.xml { head :ok }
      format.json { head :ok }
    end
  end

  protected

  #
  # Only an admin can add or remove definitions
  #
  def authorized?

    return false unless current_user

    %w{ show index tree }.include?(action_name) || current_user.is_admin?
  end
end

