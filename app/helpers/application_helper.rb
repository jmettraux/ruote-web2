
module ApplicationHelper

  def render_log_menu
    'user ' + link_to(h(current_user.login), user_path(current_user)) + ' | ' +
    link_to('logout', '/logout')
  end

  def render_res_menu

    items = %w{ processes workitems definitions history }
    items = %w{ users groups } + items if current_user.is_admin?

    items.collect { |i| "<a href='/#{i}'>#{i}</a>" }.join(' | ')
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
      #:script_name
      :path_info, ".#{format}?plain=true"
    ].inject('') do |s, elt|
      s << if elt.is_a?(String)
        elt
      elsif request.respond_to?(elt)
        request.send(elt).to_s
      else # shouldn't happen, so let's be verbose
        elt.inspect
      end
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
end

