
class UsersController < ApplicationController

  before_filter :login_required

  def new

    @user = User.new
  end

  def create

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

  #
  # Only an admin can create or delete a user.
  #
  def authorized? #(action = action_name, resource = nil)

    current_user && current_user.admin
  end
end

