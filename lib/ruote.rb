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
#

require 'openwfe/participants/participantmap'
require 'openwfe/extras/participants/activeparticipants'

require 'pagination'


module OpenWFE

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

      def activity

        h = self.field_hash

        return '-' unless h['params']

        h['params']['activity'] || h['params']['description'] || '-'
      end
    end
  end
end

#
# Opening Rails Mapper to add a wfid_resources method
#
class ActionController::Routing::RouteSet::Mapper

  def wfid_resources (controller_name)

    controller_name = controller_name.to_s

    # TODO :format ?

    # GET
    #
    connect(
      controller_name,
      :controller => controller_name,
      :action => 'index',
      :conditions => { :method => :get })
    connect(
      "#{controller_name}/:wfid",
      :controller => controller_name,
      :action => 'index_wfid',
      :conditions => { :method => :get })
    connect(
      "#{controller_name}/:wfid/:expid",
      :controller => controller_name,
      :action => 'show',
      :conditions => { :method => :get })

    connect(
      "#{controller_name}/:wfid/:expid/edit",
      :controller => controller_name,
      :action => 'edit',
      :conditions => { :method => :get })

    # (no POST)

    # PUT
    #
    connect(
      "#{controller_name}/:wfid/:expid",
      :controller => controller_name,
      :action => 'update',
      :conditions => { :method => :put })

    # DELETE
    #
    connect(
      "#{controller_name}/:wfid/:expid",
      :controller => controller_name,
      :action => 'destroy',
      :conditions => { :method => :delete })

    #
    # paths and URLs

    plural = controller_name
    singular = plural.singularize

    # ... where to add ?

    ActionView::Base.class_eval <<-EOS
      #
      # paths
      #
      def #{plural}_path (wfid=nil)
        return "/#{plural}" unless wfid
        "/#{plural}/\#{wfid}"
      end
      def #{singular}_path (o)
        "/#{plural}/\#{o.wfid}/\#{swapdots(o.expid)}"
      end
      def edit_#{singular}_path (o)
        "\#{#{singular}_path(o)}/edit"
      end
      #
      # urls
      #
      def #{plural}_url (wfid=nil)
        "\#{ request.protocol + request.host_with_port }\#{#{plural}_path(wfid)}"
      end
      def #{singular}_url (o)
        "\#{ request.protocol + request.host_with_port }\#{#{singular}_path(o)}"
      end
      def edit_#{singular}_url (o)
        "\#{ request.protocol + request.host_with_port }\#{edit_#{singular}_path(o)}"
      end
    EOS
  end
end

#
# '.' <-> '_'
#
def swapdots (s)
  (s.index('.') != nil) ? s.gsub(/\./, '_') : s.gsub(/_/, '.')
end

#
# adding Links to models' to_xml / to_json
#
module LinksMixin

  def to_xml (opts={})
    super(opts) do |xml|
      xml.links do
        links(opts).each { |l| xml.link(l) }
      end
    end
  end

  #def to_json (opts={})
  #  super(opts.merge(:methods => :links))
  #end
  def to_json (opts={})
    js = ActiveRecord::Serialization::JsonSerializer.new(self, opts)
    sr = js.serializable_record
    sr['links'] = links(opts)
    sr.to_json
  end
end

