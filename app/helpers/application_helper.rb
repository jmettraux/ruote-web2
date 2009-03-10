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


module ApplicationHelper

  def render_log_menu
    'user ' + link_to(h(current_user.login), user_path(current_user)) + ' | ' +
    link_to('logout', '/logout')
  end

  ADMIN_MENU = [
    [ 'users', 'adding/removing users' ],
    [ 'groups', 'adding/removing groups of users' ],
    [ 'errors', 'process errors tracking' ]
  ]
  REGULAR_MENU = [
    [ 'definitions', 'launching new processes' ],
    [ 'participants', '' ],
    [ 'processes', 'listing the process instances currently active' ],
    [ 'workitems', 'listing the available workitems (tasks)' ],
    [ 'history', 'browsing the engine history' ]
  ]

  def render_res_menu

    b = lambda { |a|
      a.collect { |i, t|
        link_to(i, { :controller => i }, { :title => t }) rescue i
      }.join(' | ')
    }

    s = current_user.is_admin? ?
      b.call(ADMIN_MENU) + '&nbsp;&nbsp;.&nbsp;&nbsp;' : ''

    s + b.call(REGULAR_MENU)
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
    elsif pr = opts[:process]
      "<script src=\"/processes/#{pr.wfid}/tree.js?var=proc_tree\"></script>"
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

  <script>
    var proc_tree = null;
      // initial default value (overriden by following scripts)
  </script>

  <a id='dataurl_link'>
    <canvas id="fluo" width="50" height="50"></canvas>
  </a>
  <div id='fluo_minor_toggle' style='cursor: pointer;'>more</div>

  #{tree}

  <script>
    if (proc_tree) {

      FluoCan.renderFlow(
        'fluo', proc_tree, { 'workitems': #{workitems.inspect} });

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
    }
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

