
module ApplicationHelper

  def render_menu

    items = %w{ processes logout }
    items = %w{ users } + items if current_user.is_admin?

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
end

