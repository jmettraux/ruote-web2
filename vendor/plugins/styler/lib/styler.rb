module Styler

  def stylesheets(options='')

    # Applicaton defaults
    stylesheets = ["application"]

    # Additional sheets (if requested)
    if options[:include]
      options[:include].each do |stylesheet|
        stylesheets << stylesheet
      end
    end
  
    # Controller/action sheets
    stylesheets << "#{controller.controller_name}"
    stylesheets << "#{controller.controller_name}_#{controller.action_name}"
    stylesheets << "#{controller.controller_name}/#{controller.action_name}"

    # IE6 / IE7
    stylesheets << "ie7"
    stylesheets << "ie6"

    # Add links to header
    stylesheets.collect! do |name| 
      if File.exist?("#{RAILS_ROOT}/public/stylesheets/#{name}.css")
        case name
        when "ie7"
          "<!--[if IE 7]>\n" + stylesheet_link_tag(name) + "\n<![endif]-->"
        when "ie6"
          "<!--[if IE 6]>\n" + stylesheet_link_tag(name) + "\n<![endif]-->"
        else
          stylesheet_link_tag(name)
        end
      end
    end
    stylesheets.compact.join("\n")
  end

end