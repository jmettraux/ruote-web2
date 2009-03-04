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

        #flash[:notice] = 'GroupDefinition was successfully created.'
        format.html do
          if request.env['HTTP_REFERER']
            redirect_to(:back)
          else
            redirect_to(
              :controller => :definitions,
              :action => 'show',
              :id => @group_definition.definition_id)
          end
        end
        format.xml do
          render(
            :xml => @group_definition,
            :status => :created,
            :location => @group_definition)
        end

      else

        format.html { render :action => "new" }
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
      format.html do
        if request.env['HTTP_REFERER']
          redirect_to(:back)
        else
          redirect_to(group_definitions_url)
        end
      end
      format.xml do
        head :ok
      end
    end
  end

  protected

  #
  # Only an admin can create or delete a user.
  #
  def authorized?

    current_user && current_user.is_admin?
  end
end
