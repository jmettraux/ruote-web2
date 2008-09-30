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
# This RESTful resource has no 'edit' nor 'new' view. User 'groups' for
# interaction via HTML.
#
class UserGroupsController < ApplicationController

  before_filter :login_required


  # GET /user_groups
  # GET /user_groups.xml
  #
  def index

    @user_groups = UserGroup.find(:all)

    respond_to do |format|
      format.html { redirect_to :controller => :groups, :action => :index }
      format.xml { render :xml => @user_groups }
    end
  end

  # GET /user_groups/1
  # GET /user_groups/1.xml
  #
  def show

    @user_group = UserGroup.find(params[:id])

    respond_to do |format|
      format.html do
        redirect_to(
          :controller => :groups,
          :action => :show,
          :id => @user_group.group_id)
      end
      format.xml { render :xml => @user_group }
    end
  end

  # POST /user_groups
  # POST /user_groups.xml
  #
  def create

    @user_group = UserGroup.new(params[:user_group])

    respond_to do |format|

      if @user_group.save

        #flash[:notice] = 'UserGroup was successfully created.'
        format.html do
          if request.env['HTTP_REFERER']
            redirect_to :back
          else
            redirect_to(
              :controller => :groups,
              :action => :show,
              :id => @user_group.group_id)
          end
        end
        format.xml do
          render(
            :xml => @user_group,
            :status => :created,
            :location => @user_group)
        end

      else

        format.html {
          render :controller => :groups, :action => :index }
        format.xml {
          render :xml => @user_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.xml
  #
  def destroy

    @user_group = UserGroup.find(params[:id])
    @user_group.destroy

    respond_to do |format|
      format.html do
        if request.env['HTTP_REFERER']
          redirect_to :back
        else
          redirect_to :controller => :user_groups, :action => :index
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
    def authorized? #(action = action_name, resource = nil)

      return false unless current_user

      current_user.is_admin?
    end
end
