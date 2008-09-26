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

#
# This RESTful resource has no 'edit' nor 'new' view. Use 'definitions' for
# interaction via HTML.
#
class GroupDefinitionsController < ApplicationController

  before_filter :login_required


  # GET /group_definitions
  # GET /group_definitions.xml
  #
  def index

    @group_definitions = GroupDefinition.find(:all)

    render :xml => @group_definitions
  end

  # GET /group_definitions/1
  # GET /group_definitions/1.xml
  #
  def show

    @group_definition = GroupDefinition.find(params[:id])

    render :xml => @group_definition
  end

  # POST /group_definitions
  # POST /group_definitions.xml
  #
  def create

    @group_definition = GroupDefinition.new(params[:group_definition])

    respond_to do |format|
      if @group_definition.save
        flash[:notice] = 'GroupDefinition was successfully created.'
        format.html { redirect_to(@group_definition) }
        format.xml  { render :xml => @group_definition, :status => :created, :location => @group_definition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /group_definitions/1
  # PUT /group_definitions/1.xml
  #
  def update

    @group_definition = GroupDefinition.find(params[:id])

    respond_to do |format|
      if @group_definition.update_attributes(params[:group_definition])
        flash[:notice] = 'GroupDefinition was successfully updated.'
        format.html { redirect_to(@group_definition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /group_definitions/1
  # DELETE /group_definitions/1.xml
  #
  def destroy

    @group_definition = GroupDefinition.find(params[:id])
    @group_definition.destroy

    respond_to do |format|
      format.html { redirect_to(group_definitions_url) }
      format.xml  { head :ok }
    end
  end

  protected

    #
    # Only an admin can create or delete a user.
    #
    def authorized? #(action = action_name, resource = nil)

      current_user && current_user.is_admin?
    end
end
