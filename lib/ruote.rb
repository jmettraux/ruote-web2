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
# this lib/ruote.rb is 'required' by the ruote_plugin if present.
# it won't get required when using rake or script/generate
#

require 'openwfe/participants/participant_map'
require 'openwfe/extras/participants/active_participants'

require 'pagination'


class ActiveRecord::ConnectionAdapters::AbstractAdapter
  # original :
  #
  #def decrement_open_transactions
  #  @open_transactions -= 1
  #end
  def decrement_open_transactions
    @open_transactions && @open_transactions -= 1
  end
end


module OpenWFE

  #
  # Reopening the ParticipantMap to change the lookup_participant rules
  #
  # If no formally registered participant is found, the system will
  # put the workitem in a store. If the participant corresponds to a user name
  # or a user group, the store name will be that user or group name.
  # Else, the store name will be 'unknown' (workitems that have gone astray).
  #
  class ParticipantMap

    alias :old_lookup_participant :lookup_participant

    def lookup_participant (participant_name)

      part = old_lookup_participant(participant_name)

      return part if part

      #target =
      #  User.find_by_login(participant_name) ||
      #  Group.find_by_name(participant_name)
      #store_name = target ? participant_name : 'unknown'

      store_name = participant_name

      OpenWFE::Extras::ActiveStoreParticipant.new(store_name)
        # returns an 'on the fly' participant
    end
  end

  class ProcessStatus

    #
    # Returning the launcher of this process instance (if set)
    #
    def launcher

      self.variables['launcher']
    end
  end

  class FlowExpressionId

    def to_web_s
      si = sub_instance_id == '' ? '' : "#{sub_instance_id} "
      "#{si}#{expid} #{expname}"
    end
  end

  module Extras

    class Workitem

      #
      # returns an 'activity' description, if any
      #
      def activity

        h = self.field_hash

        return '-' unless h['params']

        h['params']['activity'] || h['params']['description'] || '-'
      end
    end
  end
end

