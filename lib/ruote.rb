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

#
# this lib/ruote.rb is 'required' by the ruote_plugin if present.
# it won't get required when using rake or script/generate
#

require 'openwfe/participants/participantmap'
require 'openwfe/extras/participants/activeparticipants'

require 'pagination'


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

      store_name =
        User.find_by_login(participant_name) ||
        Group.find_by_name(participant_name)
      store_name = store_name ? store_name.system_name : 'unknown'

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

