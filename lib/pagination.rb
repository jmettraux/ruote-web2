#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
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

    conditions = paginate_options[:conditions] || {}

    conditions = parcol_array.inject(conditions) do |h, k|
      k = Array(k)
      key = k[0]
      col = k[1] || key
      val = params[key]
      h[col] = val if val
      h
    end

    paginate_options[:conditions] = conditions

    paginate_options[:page] = params[:page]

    #p paginate_options

    paginate(paginate_options)
  end
end

