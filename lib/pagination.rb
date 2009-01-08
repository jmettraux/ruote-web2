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

#
# a small convenience method for
# will_paginate (http://github.com/mislav/will_paginate)
#
module WillPaginate::Finder::ClassMethods

  #
  # an usage example : app/controllers/workitems_controller#index()
  #
  #   OpenWFE::Extras::Workitem.paginate_by_params(
  #     [
  #       # parameter_name[, column_name]
  #       'wfid',
  #       [ 'workflow', 'wf_name' ],
  #       [ 'store', 'store_name' ],
  #       [ 'participant', 'participant_name' ]
  #     ],
  #     params,
  #     :order => 'dispatch_time DESC')
  #
  def paginate_by_params (parcol_array, params, paginate_options={})

    cols, vals = parcol_array.inject([[], []]) do |a, k|
      k = Array(k)
      key = k[0]
      col = k[1] || key
      val = params[key]
      if val
        a.first << col
        a.last << val
      end
      a
    end

    unless cols.empty?

      conditions = cols.collect { |col| "#{col} = ?" }.join(' AND ')
      conditions = [ conditions ] + vals

      paginate_options[:conditions] = conditions
    end

    paginate_options[:page] = params[:page]

    #p paginate_options

    paginate(paginate_options)
  end
end

