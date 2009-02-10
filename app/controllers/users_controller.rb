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

class UsersController < ApplicationController

  before_filter :login_required

  def index

    @users = User.find(:all)

    # TODO : paginate ?

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @users }
      format.json { render :json => @users }
    end
  end

  def show

    load_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.json  { render :json => @user }
    end
  end

  def edit
    load_user_and_groups
  end

  def new
    @user = User.new
  end

  def create

    # TODO : let it accept XML

    logout_keeping_session!

    @user = User.new(params[:user])

    success = @user && @user.save

    if success && @user.errors.empty?

      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      #self.current_user = @user # !! now logged in

      flash[:notice] = "user '#{@user}' created"
      redirect_back_or_default('/')

    else

      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  # PUT /users/1
  #
  def update

    load_user_and_groups

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy

    load_user

    raise ErrorReply.new("no user #{params[:id]}", 404) unless @user

    # TODO : clean up that error handling stuff

    respond_to do |format|
      if @user.destroy
        flash[:notice] = "User #{@user.login} was removed."
        format.html { redirect_to users_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'failed to remove user'
        format.html { render :action => 'edit' }
        format.xml  { render :text => flash[:error], :status => 500 }
      end
    end
  end

  protected

  #
  # Only an admin can create or delete a user.
  #
  def authorized?

    return false unless current_user

    %w{ show index }.include?(action_name) || current_user.is_admin?
  end

  #
  # TODO : is it worth it ? what about a redirection to /users/1 ?
  #
  def load_user
    i = params[:id].to_i
    @user = i == 0 ? User.find_by_login(params[:id]) : User.find(i)
  end

  def load_user_and_groups
    load_user
    @ug_locals = {
      :in_elements => @user.user_groups,
      :out_elements => Group.find(:all) - @user.groups
    }
  end
end

