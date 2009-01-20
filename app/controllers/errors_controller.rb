#
#--
# Copyright (c) 2009, John Mettraux, OpenWFE.org
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

# "Made in Japan" as opposed to "Swiss Made"

#
# ruote-web2 uses db_error_journal, so tapping directly into the db is OK
#
class ErrorsController < ApplicationController

  before_filter :login_required

  # GET /errors
  #
  def index

    opts = { :page => params[:page], :order => 'created_at DESC' }

    @all = (opts[:conditions] == nil)
    @errors = OpenWFE::Extras::ProcessError.paginate(opts)

    respond_to do |format|

      format.html # => app/views/errors/index.html.erb

      format.json do
        render(:json => OpenWFE::Json.errors_to_h(
          @errors,
          :linkgen => LinkGenerator.new(request)).to_json)
      end

      format.xml do
        render(
          :xml => OpenWFE::Xml.errors_to_xml(
            @errors,
            :linkgen => LinkGenerator.new(request), :indent => 2))
      end
    end
  end

  protected

    def authorized? (action=action_name, resource=nil)

      # TODO : restrict to admins !

      (current_user != nil) # do I really need that ?...
    end
end

