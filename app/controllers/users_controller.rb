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

    @user = User.new(params[:user])

    success = @user && @user.save

    if success && @user.errors.empty?

      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      #self.current_user = @user # !! now logged in

      flash[:notice] = "user '#{@user.login}' created"
      redirect_to :controller => :users, :action => :index

    else

      #flash[:error]  = "failed to set up account"
      redirect_to :controller => :users, :action => :index
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

