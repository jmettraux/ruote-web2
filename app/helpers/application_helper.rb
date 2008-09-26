
module ApplicationHelper

  def render_log_menu
    'user ' + link_to(h(current_user.login), user_path(current_user)) + ' | ' +
    link_to('logout', '/logout')
  end

  def render_res_menu

    items = %w{ processes workitems definitions }
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
  # FLUO
  #
  def render_fluo (opts)

    rep = if d = opts[:definition]
      "<script src=\"/definition/#{d.id}/tree.js&var=proc_rep\"></script>"
    elsif p = opts[:process]
      "<script src=\"/processes/#{p.wfid}/tree.js&var=proc_rep\"></script>"
    elsif t = opts[:tree]
      "<script>var proc_rep = #{t.to_json};</script>"
    else
      '<script>var proc_rep = null;</script>'
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

  <canvas id="fluo" width="50" height="50"></canvas>
  #{rep}
  <script>
    if (proc_rep) {
      FluoCan.renderFlow('fluo', proc_rep, {'workitems': #{workitems.inspect}});
      FluoCan.crop('fluo');#{hl}
    }
  </script>

  <div style='margin-top: 14px;'>
    <a id="dataurl_link" href="">graph data url</a>
    <script>
      var a = document.getElementById('dataurl_link');
      a.href = document.getElementById('fluo').toDataURL();
    </script>
  </div>
    }
  end
end

