#
#--
# Copyright (c) 2008-2009, John Mettraux OpenWFE.org
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

module ApplicationHelper

  def render_log_menu
    'user ' + link_to(h(current_user.login), user_path(current_user)) + ' | ' +
    link_to('logout', '/logout')
  end

  def render_res_menu

    b = lambda { |a|
      a.collect { |i| link_to(i, :controller => i) rescue i }.join(' | ')
    }

    s = current_user.is_admin? ?
      b.call(%w{ users groups }) + '&nbsp;&nbsp;.&nbsp;&nbsp;' : ''

    s + b.call(%w{ definitions participants processes workitems errors history })
  end

  #
  #     display_time(workitem.dispatch_time)
  #         # => Sat Mar 1 20:29:44 2008 (1d16h18m)
  #
  #     display_time(workitem, :dispatch_time)
  #         # => Sat Mar 1 20:29:44 2008 (1d16h18m)
  #
  def display_time (object, accessor=nil)

    t = accessor ?  object.send(accessor) : object

    return "" unless t

    "#{t.ctime} (#{display_since(t)})"
  end

  #
  #     display_since(workitem, :dispatch_time)
  #         # => 1d16h18m
  #
  def display_since (object, accessor=nil)

    t = accessor ? object.send(accessor) : object

    return "" unless t

    d = Time.now - t

    Rufus::to_duration_string(d, :drop_seconds => true)
  end

  def comma_list (objects, accessor=:name)

    objects.collect { |o|
      name = o.send(accessor)
      path = send "#{o.class.to_s.downcase}_path", o
      link_to(h(name), path)
    }.join(', ')
  end

  #
  # given a view, returns the link to the same view in another content type
  # (xml / json)
  #
  def as_x_href (format)

    href = [
      :protocol, :host, ':', :port,
      :request_uri, ".#{format}?plain=true"
    ].inject('') do |s, elt|
      s << if elt.is_a?(String)
        elt
      elsif request.respond_to?(elt)
        request.send(elt).to_s
      else # shouldn't happen, so let's be verbose
        elt.inspect
      end
      s
    end
    href << "&#{request.query_string}" if request.query_string.length > 0
    href
  end

  #
  # FLUO
  #
  def render_fluo (opts)

    tree = if d = opts[:definition]
      "<script src=\"/definitions/#{d.id}/tree.js?var=proc_tree\"></script>"
    elsif p = opts[:process]
      "<script src=\"/processes/#{p.wfid}/tree.js?var=proc_tree\"></script>"
    elsif i = opts[:wfid]
      "<script src=\"/processes/#{i}/tree.js?var=proc_tree\"></script>"
    elsif t = opts[:tree]
      "<script>var proc_tree = #{t.to_json};</script>"
    else
      '<script>var proc_tree = null;</script>'
    end

    hl = if e = opts[:expid]
      "\nFluoCan.highlight('fluo', '#{e}');"
    else
      ''
    end

    workitems = Array(opts[:workitems])

    %{
  <!-- fluo -->

  <script src="/javascripts/fluo-json.js"></script>
  <script src="/javascripts/fluo-can.js"></script>

  <a id='dataurl_link'>
    <canvas id="fluo" width="50" height="50"></canvas>
  </a>
  <div id='fluo_minor_toggle' style='cursor: pointer;'>more</div>

  #{tree}

  <script>
    FluoCan.renderFlow('fluo', proc_tree, {'workitems': #{workitems.inspect}});
    FluoCan.toggleMinor('fluo');
    FluoCan.crop('fluo');#{hl}

    var a = document.getElementById('dataurl_link');
    a.href = document.getElementById('fluo').toDataURL();

    var toggle = document.getElementById('fluo_minor_toggle');
    toggle.onclick = function () {
      FluoCan.toggleMinor('fluo');
      FluoCan.crop('fluo');
      if (toggle.innerHTML == 'more') toggle.innerHTML = 'less'
      else toggle.innerHTML = 'more';
    };
  </script>
    }
  end

  #
  # used to build links to things like /workitems?wfid=xyz or
  # /processes?workflow=cheeseburger_order
  #
  def link_to_slice (item, accessor, param_name=nil)

    v = h(item.send(accessor))
    link_to(v, (param_name || accessor) => v)
  end
end

