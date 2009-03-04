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
# Opening Rails Mapper to add a wfid_resources method
#
class ActionController::Routing::RouteSet::Mapper

  def wfid_resources (controller_name)

    controller_name = controller_name.to_s

    # GET
    #
    connect(
      controller_name,
      :controller => controller_name,
      :action => 'index',
      :conditions => { :method => :get })
    connect(
      "#{controller_name}.:format",
      :controller => controller_name,
      :action => 'index',
      :conditions => { :method => :get })

    connect(
      "#{controller_name}/:wfid",
      :controller => controller_name,
      :action => 'index',
      :conditions => { :method => :get })

    connect(
      "#{controller_name}/:wfid/:expid",
      :controller => controller_name,
      :action => 'show',
      :conditions => { :method => :get })
    connect(
      "#{controller_name}/:wfid/:expid.:format",
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
    connect(
      "#{controller_name}/:wfid/:expid.:format",
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
    connect(
      "#{controller_name}/:wfid/:expid.:format",
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
        o = o.fei if o.is_a?(OpenWFE::FlowExpression)
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
# '_' --> '.'
#
def swap_to_dots (s)
  (s.index('.') != nil) ? s : s.gsub(/_/, '.')
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

